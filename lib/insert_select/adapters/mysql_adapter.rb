module InsertSelect
  module Adapters
    class MysqlAdapter < BaseAdapter
      def initialize(table_name, connection)
        @table_name = table_name
        @connection = connection
      end

      def build_sql(builder)
        sql = super

        sql
      end
    end
  end
end
