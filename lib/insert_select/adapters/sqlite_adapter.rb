module InsertSelect
  module Adapters
    class SqliteAdapter < BaseAdapter
      def initialize(table_name, connection)
        @table_name = table_name
        @connection = connection
      end

      def build_sql(builder)
        # have to be done before we call super, because super will make relation immutable
        if builder.on_duplicate == :skip
          builder.relation.where!("TRUE") if builder.relation.where_clause.blank?
        end

        stmt = super

        if builder.on_duplicate == :skip
          stmt << " ON CONFLICT DO NOTHING" 
        end

        stmt
      end
    end
  end
end
