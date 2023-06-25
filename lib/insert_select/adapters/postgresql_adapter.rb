module InsertSelect
  module Adapters
    class PostgresqlAdapter < BaseAdapter
      def initialize(table_name, connection)
        @table_name = table_name
        @connection = connection
      end

      def build_sql(builder)
        sql = super

        sql << " RETURNING #{builder.returning}" if builder.returning
        sql << " ON CONFLICT DO NOTHING" if builder.on_duplicate == :skip

        sql
      end
    end
  end
end
