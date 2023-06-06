module InsertSelect
  module Adapters
    class BaseAdapter
      def initialize(table_name, connection)
        @table_name = table_name
        @connection = connection
      end

      def insert_select_from(relation, options = {})
        @connection.execute(to_sql(relation, options))
      end

      private

      def to_sql(relation, options)
        select_values = relation.select_values
        columns = relation.select_values.map {|column|
          name = options[:mapping] && options[:mapping][column] || column
          @connection.quote_column_name(name)
        }
        quoted_table_name = @connection.quote_table_name(@table_name)

        binding.irb
        stmt = "INSERT INTO #{quoted_table_name} "
        stmt += "(#{columns.join(', ')}) " if columns.present?
        stmt += relation.to_sql
      end
    end
  end
end
