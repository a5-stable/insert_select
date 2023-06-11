module InsertSelect
  module Adapters
    require "insert_select/errors"

    class BaseAdapter
      def initialize(table_name, connection)
        @table_name = table_name
        @connection = connection
      end

      def insert_select_from(relation, options = {})
        @connection.execute(to_sql(relation.all, options))
      end

      private

      def to_sql(relation, options)
        mapping = options[:mapping] || {}
        selected_column_names = relation.select_values
        mapping_column_names = mapping.keys

        # if selected_column_names.blank? && @connection.columns(@table_name).size != @connection.columns(relation.table_name).size
        #   raise InsertSelect::ColumnCountMisMatchError.new("hello")
        # end

        columns = []

        if selected_column_names.present?
          selected_column_names.each do |column_name|
            if mapping[column_name]
              columns << mapping[column_name]
              mapping_column_names.delete(column_name)
            else
              columns << column_name
            end
          end
        end

        if mapping_column_names.present?
          columns += @connection.columns(relation.table_name).map{|c| mapping[c.name.to_sym] || c.name}
        end

        if options[:constant].present?
          columns += @connection.columns(relation.table_name).map{|c| c.name.to_sym if selected_column_names.blank? || selected_column_names.include?(c.name.to_sym)}.compact
          columns.uniq!
          columns.each do |column_name|
            relation = relation.select("#{column_name}") if selected_column_names.exclude?(column_name)
          end

          options[:constant].each {|k, v|
            relation = relation.select("'#{v}' AS #{k}")
          }
          columns += options[:constant].keys
        end

        columns = columns.map {|c| @connection.quote_column_name(c)}
        quoted_table_name = @connection.quote_table_name(@table_name)

        stmt = "INSERT INTO #{quoted_table_name} "
        stmt += "(#{columns.uniq.join(', ')}) " if columns.present?
        stmt += relation.to_sql

        puts stmt
        stmt
      end
    end
  end
end
