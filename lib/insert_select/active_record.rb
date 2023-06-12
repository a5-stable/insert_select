require 'active_support/concern'

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
          InsertSelect::ActiveRecord::InsertSelectFrom.new(self, relation, mapping: {}, constant: {}, returning: nil, record_timestamps: nil).execute
        end
      end
    end

    class InsertSelectFrom
      attr_reader :model, :connection, :relation, :adapter, :mapping, :constant, :returning, :record_timestamps

      def initialize(model, relation, mapping:, constant:, returning:, record_timestamps:)
        @model = model
        @connection = model.connection
        @relation = relation
        @adapter = find_adapter(connection)
      end

      def to_sql
        adapter.build_sql(Builder.new(self))
      end

      def execute
        connection.execute(to_sql)
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

      class Builder
        attr_reader :relation, :constant, :mapping, :returning, :record_timestamps
        def initialize(insert_select_from)
          @relation = insert_select_from.relation
          @constant = insert_select_from.constant
          @mapping = insert_select_from.mapping
          @returning = insert_select_from.returning
          @record_timestamps = insert_select_from.record_timestamps
        end
      end
    end
  end
end
