module InsertSelect
  module Adapters
    class SqliteAdapter < BaseAdapter
      def initialize(table_name, connection)
        @table_name = table_name
        @connection = connection
      end

      def build_sql(builder)
        super
      end
    end
  end
end
