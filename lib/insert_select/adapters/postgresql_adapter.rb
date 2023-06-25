module InsertSelect
  module Adapters
    class PostgresqlAdapter < BaseAdapter
      def initialize(table_name, connection)
        @table_name = table_name
        @connection = connection
      end

      def build_sql(builder)
        sql = super
        sql += " RETURNING #{builder.returning}" if builder.returning

        if builder.on_duplicate == :skip
          stmt << "WHERE 1 " if builder.relation.where_clause.blank?
          stmt << " ON CONFLICT DO NOTHING" 
        end

        sql
      end
    end
  end
end
