module InsertSelect
  module Adapters
    class MysqlAdapter < BaseAdapter
      def initialize(table_name, connection)
        @table_name = table_name
        @connection = connection
      end

      def build_sql(builder)
        into = builder.into

        if into.present?
          builder.reselect_relation!

          stmt = "INSERT #{into}"
          stmt << " #{builder.relation_sql}"

          if builder.on_duplicate == :skip
            stmt << "WHERE 1 " if builder.relation.where_clause.blank?
            stmt << " ON CONFLICT DO NOTHING" 
          end
        else
          quoted_table_name = @connection.quote_table_name(table_name)
          stmt = "INSERT INTO #{quoted_table_name}"
          stmt << " #{builder.relation_sql}"

          if builder.on_duplicate == :skip
            stmt << " WHERE 1" if builder.relation.where_clause.blank?
            stmt << " ON CONFLICT DO NOTHING" 
          end
        end

        stmt
      end
    end
  end
end
