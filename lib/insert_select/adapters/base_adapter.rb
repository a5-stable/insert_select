module InsertSelect
  module Adapters
    class BaseAdapter
      def initialize(table_name, connection)
        @table_name = table_name
        @connection = connection
      end

      def insert_select_from(relation)
        @connection.execute(to_sql(relation))
      end

      private

      def to_sql(relation)
        columns = relation.select_values.map {|column| @connection.quote_column_name(column)}
        quoted_table_name = @connection.quote_table_name(@table_name)

        stmt = "INSERT INTO #{quoted_table_name} "
        stmt += relation.to_sql
      end
    end
  end
end
