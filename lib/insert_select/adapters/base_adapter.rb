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
        mapping = options[:mapping] || {}
        selected_column_names = relation.select_values
        mapping_column_names = mapping.keys
        columns = []

        selected_column_names.each do |column_name|
          if mapping[column_name] && mapping[column_name].is_a?(Symbol)
            columns << mapping[column_name]
            mapping_column_names.delete(column_name)
          else
            columns << column_name
          end
        end

        mapping_column_names.each do |column_name|
          columns << column_name
          relation = relation.select(:"#{mapping[column_name]}")
        end

        columns = columns.map {|c| @connection.quote_column_name(c)}
        quoted_table_name = @connection.quote_table_name(@table_name)

        stmt = "INSERT INTO #{quoted_table_name} "
        stmt += "(#{columns.uniq.join(', ')}) " if columns.present?
        stmt += relation.to_sql
      end
    end
  end
end
