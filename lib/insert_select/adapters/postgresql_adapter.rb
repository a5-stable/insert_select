module InsertSelect
  module Adapters
    class PostgresqlAdapter < BaseAdapter
      def initialize(table_name, connection)
        @table_name = table_name
        @connection = connection
      end

      def build_sql(builder)
        stmt = super

        stmt << " ON CONFLICT DO NOTHING" if builder.on_duplicate == :skip
        stmt << " RETURNING #{builder.returning}" if builder.returning?

        stmt
      end
    end
  end
end
