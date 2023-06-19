module InsertSelect
  module ActiveRecord
    class Builder
      attr_reader :relation, :mapping, :model, :returning, :insert_select_from, :connection

      def initialize(insert_select_from)
        @insert_select_from = insert_select_from
        @connection = insert_select_from.connection
        @relation = insert_select_from.relation.all
        @mapping = insert_select_from.mapping || {}
        @model = insert_select_from.model
        @returning = insert_select_from.returning
      end

      def mapper
        @mapper ||= begin
          result = {}
          insert_mapping = mapping.transform_keys(&:to_s)
          mapping_column_names = mapping.keys

          # selected & mapped
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

          # not selected & mapped
          if mapping_column_names.present?
            @connection.columns(relation.table_name).map{|c|
              insert_mapping[c.name.to_s] = mapping[c.name.to_sym] || c.name
            }
          end

          # not selected & not mapped & constantized for insert mapping
          constant_mapping = {}
          if insert_mapping.blank? && constant.present?
            @connection.columns(relation.table_name).map{|c|
              insert_mapping[c.name.to_s] = c.name
            }
          end

          # constantized for insert mapping & constant mapping
          constant.each {|k, v|
            insert_mapping.delete(k.to_s)
            constant_mapping[k.to_s] = "\"#{v}\""
          }

          result[:insert_mapping] = insert_mapping
          result[:constant_mapping] = constant_mapping

          result
        end
      end

      def insert_mapping
        @insert_mapping ||= mapper[:insert_mapping]
      end

      def constant_mapping
        @constant_mapping ||= mapper[:constant_mapping]
      end

      def into
        return nil if insert_mapping.blank? && constant_mapping.blank? && constant_values.blank?
        "INTO #{model.quoted_table_name} (#{inserting_column_names.join(", ")})"
      end

      def values_list
        keys = model.column_names.map(&:to_sym)
        types = keys.index_with { |key| model.type_for_attribute(key) }

        values_list = insert_select_from.map_key_with_value do |key, value|
          next value if Arel::Nodes::SqlLiteral === value
          @connection.with_yaml_fallback(types[key].serialize(value))
        end

        connection.visitor.compile(Arel::Nodes::ValuesList.new(values_list))
      end

      def extract_types_from_columns_on(table_name, keys:)
        columns = @connection.schema_cache.columns_hash(model.table_name)

        # unknown_column = (keys - columns.keys).first
        # raise UnknownAttributeError.new(model.new, unknown_column) if unknown_column

        keys.index_with { |key| model.type_for_attribute(key) }
      end

      def inserting_column_names
        (insert_mapping.values + constant_mapping.keys + constant_values.keys).map {|k| @connection.quote_column_name(k) }
      end

      def relation_sql
        relation.to_sql
      end

      def constant_values
        model.scope_attributes
      end

      def reselect_relation!
        current_selected_column_names = relation.select_values.map(&:to_s)

        insert_mapping.keys.each do |k, v|
          relation._select!(k) if current_selected_column_names.exclude?(k.to_s)
        end

        constant_mapping.keys.each do |k, v|
          relation._select!("?")
          remove_select_values!(k)
        end
      end

      def returning
        return unless @returning

        if @returning.is_a?(String)
          @returning
        else
          Array( @returning ).map do |attribute|
            if model.attribute_alias?(attribute)
              "#{@connection.quote_column_name(model.attribute_alias(attribute))} AS #{@connection.quote_column_name(attribute)}"
            else
              @connection.quote_column_name(attribute)
            end
          end.join(",")
        end
      end

      private

      def remove_select_values!(column_name)
        relation.select_values = relation.select_values - [column_name.to_sym]
      end

      def selected_column_names
        relation.select_values
      end

    end
  end
end
