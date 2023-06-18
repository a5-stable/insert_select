require 'active_support/concern'
require_relative "builder"

module InsertSelect
  module ActiveRecord
    extend ActiveSupport::Concern
    require_relative "adapters/base_adapter"
    require_relative "adapters/postgresql_adapter"
    require_relative "adapters/mysql_adapter"
    require_relative "adapters/sqlite_adapter"

    included do
      class << self
        #
        # Copy data from the specified data source to the table of the model easily.
        #
        # @example Filter the columns to be copied
        # 
        # NewUser.insert_select_from(OldUser.select(:name))
        # #=> INSERT INTO "new_users" ("name") SELECT "old_users"."name" FROM "old_users"
        #
        # To see more examples, please refer to the [README](https://github.com/a5-stable/insert_select#readme)
        #
        # @param [ActiveRecord::Relation] relation 
        #        The data source to be copied.
        #
        # @param [Hash] mapping 
        #        The column mapping hash. Specify the mapping when the column name is different between the source table and the destination table.
        #        Usage: { source_column_name: :destination_column_name }
        #
        # @param [Hash] constant 
        #        The constant value hash. You can specify constant values for columns.
        #        Usage: { column_name: constant_value }
        #        Please note that constant values take precedence over the mapping specification.
        #
        # @param returning 
        #        The returning clause option (only for PostgreSQL connection).
        #
        # @return [ActiveRecord::Result] The result of the insert select operation.
        #
        def insert_select_from(relation, mapping: {}, constant: {}, returning: nil)
          InsertSelect::ActiveRecord::InsertSelectFrom.new(self, relation, mapping: mapping, constant: constant, returning: returning).execute
        end

        def except(*columns)
          select( column_names - columns.map(&:to_s) )
        end
      end
    end

    class InsertSelectFrom
      attr_reader :model, :connection, :relation, :adapter, :mapping, :constant, :returning

      def initialize(model, relation, mapping:, constant:, returning: nil)
        @model = model
        @connection = model.connection
        @relation = relation
        @adapter = find_adapter(connection)
        @mapping = mapping
        @constant = constant
        @returning = returning
      end

      def execute
        sql = model.sanitize_sql_array([to_sql, *builder.constant_values])
        connection.exec_insert_all(sql, "")
      end

      def to_sql
        @to_sql ||= adapter.build_sql(builder)
      end

      def builder
        @builder ||= Builder.new(self)
      end

      def ensure_valid_options_for_connection!
        if returning && !connection.supports_insert_returning?
          raise ArgumentError, "#{connection.class} does not support :returning"
        end
      end

      private

      def find_adapter(connection)
        table_name = model.table_name
        case connection.adapter_name.to_s.downcase
        when /mysql/
          InsertSelect::Adapters::MysqlAdapter.new(table_name, connection)
        when /postgresql/
          InsertSelect::Adapters::PostgresqlAdapter.new(table_name, connection)
        when /sqlite/
          InsertSelect::Adapters::SqliteAdapter.new(table_name, connection)
        else
          raise "Unsupported adapter: #{connection.adapter_name}"
        end
      end
    end
  end
end
