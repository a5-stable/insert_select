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
        def insert_select_from(relation, options = {})
          InsertSelect::ActiveRecord::InsertSelectFrom.new(self, relation, mapping: options[:mapping], constant: options[:constant]).execute
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
        connection.execute(sql)
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
        when "PostgreSQL"
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
