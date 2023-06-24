module InsertSelect
  module ActiveRecord
    class Builder
      attr_reader :relation, :mapping, :model,:insert_select_from, :connection, :returning, :record_timestamps

      def initialize(insert_select_from)
        @insert_select_from = insert_select_from
        @connection = insert_select_from.connection
        @relation = insert_select_from.relation.all
        @mapping = insert_select_from.mapping || {}
        @model = insert_select_from.model
        @returning = insert_select_from.returning
        @record_timestamps = insert_select_from.record_timestamps
      end

      def mapper
        @mapper ||= begin
          result = {}
          insert_mapping = {}

          if selected_column_names.present?
            selected_column_names.each do |column_name|
              insert_mapping[column_name.to_s] = mapping[column_name.to_sym] || column_name
            end
          elsif mapping.present? || model.scope_attributes.present?
            @connection.columns(relation.table_name).each do |column|
              insert_mapping[column.name.to_s] =  mapping[column.name.to_sym] || column.name
            end
          end

          model.scope_attributes.keys.each {|column_name| insert_mapping.delete(column_name.to_s) }

          result[:insert_mapping] = insert_mapping
          result[:constant_mapping] = model.scope_attributes || {}

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
        return nil if insert_mapping.blank? && constant_mapping.blank?
        "INTO #{model.quoted_table_name} (#{inserting_column_names.join(", ")})"
      end

      def inserting_column_names
        column_names = insert_mapping.values + constant_mapping.keys
        column_names += model.all_timestamp_attributes_in_model if record_timestamps
        (column_names).map {|c| @connection.quote_column_name(c) }
      end

      def relation_sql
        relation.to_sql
      end

      def constant_values
        constant_mapping.values
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
