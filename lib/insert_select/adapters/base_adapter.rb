module InsertSelect
  module Adapters
    require "insert_select/errors"

    class BaseAdapter
      attr_reader :table_name, :connection
      def initialize(table_name, connection)
        @table_name = table_name
        @connection = connection
      end

      def build_sql(builder)
        relation = builder.relation.all
        mapper = builder.mapper
        insert_mapping = mapper[:insert_mapping]
        constant_mapping = mapper[:constant_mapping]
        quoted_table_name = @connection.quote_table_name(table_name)

        if insert_mapping.present? || constant_mapping.present?
          c = []
          insert_mapping.each {|k, v|
            c << v
            relation = relation.select(k.to_s) if builder.selected_column_names.map(&:to_s).exclude?(k.to_s)
          }

          constant_mapping.each {|k, v|
            c << k
            relation.select_values = relation.select_values - [k.to_sym]
            relation = relation.select(v)
          }
          stmt = "INSERT INTO #{quoted_table_name} "
          stmt += "(#{c.join(', ')}) "
          stmt += relation.to_sql

          stmt
        else
          stmt = "INSERT INTO #{quoted_table_name} #{relation.to_sql}"
        end

        stmt
      end
    end
  end
end
