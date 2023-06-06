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
          adapter = find_adapter(connection)
          adapter.insert_select_from(relation, options)
        end

        private

        def find_adapter(connection)
          case connection.adapter_name
          when /MySQL2/
            InsertSelect::Adapters::MysqlAdapter.new(table_name, connection)
          when "PostgreSQL"
            InsertSelect::Adapters::PostgresqlAdapter.new(table_name, connection)
          when /SQLite/
            InsertSelect::Adapters::SqliteAdapter.new(table_name, connection)
          else
            raise "Unsupported adapter: #{connection.adapter_name}"
          end
        end
      end
    end
  end
end
