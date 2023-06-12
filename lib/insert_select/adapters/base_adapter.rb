module InsertSelect
  module Adapters
    require "insert_select/errors"

    class BaseAdapter
      def initialize(table_name, connection)
        @table_name = table_name
        @connection = connection
      end

      def build_sql(insert_select_from)
        mapping = insert_select_from.mapping || {}
        constant = insert_select_from.constant || {}
        relation = insert_select_from.relation

        insert_mapping = mapping.transform_keys(&:to_s)
        selected_column_names = relation.select_values
        mapping_column_names = mapping.keys

        if selected_column_names.present?
          selected_column_names.each do |column_name|
            if mapping[column_name]
              insert_mapping[column_name.to_s] = mapping[column_name]
              mapping_column_names.delete(column_name)
            else
              insert_mapping[column_name.to_s] = column_name
            end
          end
        end

        if mapping_column_names.present?
          @connection.columns(relation.table_name).map{|c|
            insert_mapping[c.name.to_s] = mapping[c.name.to_sym] || c.name
          }
        end

        if constant.present?
          if insert_mapping.blank?
            @connection.columns(relation.table_name).map{|c|
              insert_mapping[c.name.to_s] = c.name
            }
          end

          constant.each {|k, v|
            insert_mapping.delete(k.to_s)
            relation.select_values = relation.select_values - [k.to_sym]
            insert_mapping["\"#{v}\""] = k
          }
        end

        quoted_table_name = @connection.quote_table_name(@table_name)

        if insert_mapping.present?
          c = []
          insert_mapping.each {|k, v|
            c << v
            relation = relation.select(k.to_s) if selected_column_names.map(&:to_s).exclude?(k.to_s)
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
