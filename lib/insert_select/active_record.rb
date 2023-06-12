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
          InsertSelectFrom.new(self, relation, returning: nil, record_timestamps: nil, options).execute
        end

        private

        class InsertSelectFrom
          attr_reader :model, :connection, :relation, :adapter

          def initialize(model, relation, returning: returning, record_timestamps: record_timestamps, options)
            @model = model
            @connection = model.connection
            @relation = relation
            @adapter = find_adapter(connection)
          end

          def to_sql
            adapter.build_sql(ActiveRecord::InsertSelectFrom::Builder.new(self))
          end

          def execute
            connection.execute(to_sql)
          end

          private

          def find_adapter
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
            def initialize(insert_select_from)
            end
          end
        end
      end
    end
  end
end
