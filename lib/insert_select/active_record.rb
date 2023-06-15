require 'active_support/concern'

module InsertSelect
  module ActiveRecord
    extend ActiveSupport::Concern
    require_relative "adapters/base_adapter"
    require_relative "adapters/postgresql_adapter"
    require_relative "adapters/mysql_adapter"
    require_relative "adapters/sqlite_adapter"

    included do
      class << self
        def insert_select_from(relation, options = {})
          InsertSelect::ActiveRecord::InsertSelectFrom.new(self, relation, mapping: options[:mapping], constant: options[:constant]).execute
        end
      end
    end

    class InsertSelectFrom
      attr_reader :model, :connection, :relation, :adapter, :mapping, :constant

      def initialize(model, relation, mapping:, constant:)
        @model = model
        @connection = model.connection
        @relation = relation
        @adapter = find_adapter(connection)
        @mapping = mapping
        @constant = constant
      end

      def to_sql
        @to_sql ||= adapter.build_sql(builder)
      end

      def execute
        sql = model.sanitize_sql_array([to_sql, *builder.constant_values])
        connection.execute(sql)
      end

      def builder
        @builder ||= Builder.new(self)
      end

      def update_duplicates?
        on_duplicate == :update
      end

      def update_duplicates?
        on_duplicate == :update
      end

      def record_timestamps?
        @record_timestamps
      end

      private

      def find_adapter(connection)
        table_name = model.table_name
        case connection.adapter_name.to_s.downcase
        when /mysql/
          InsertSelect::Adapters::MysqlAdapter.new(table_name, connection)
        when "PostgreSQL"
          InsertSelect::Adapters::PostgresqlAdapter.new(table_name, connection)
        when /sqlite/
          InsertSelect::Adapters::SqliteAdapter.new(table_name, connection)
        else
          raise "Unsupported adapter: #{connection.adapter_name}"
        end
      end

      class Builder
        attr_reader :relation, :constant, :mapping, :model, :constant_values

        def initialize(insert_select_from)
          @connection = insert_select_from.connection
          @relation = insert_select_from.relation.all
          @constant = insert_select_from.constant || {}
          @mapping = insert_select_from.mapping || {}
          @model = insert_select_from.model
          @constant_values = @constant.values
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
          return nil if insert_mapping.blank? && constant_mapping.blank?

          c = []
          insert_mapping.each {|k, v|
            c << v
            relation._select!(k) if selected_column_names.map(&:to_s).exclude?(k.to_s)
          }

          constant_mapping.each {|k, v|
            c << k
            relation._select!("?")
            remove_select_values!(k)
          }

          "INTO #{model.quoted_table_name} (#{c.join(', ')})"
        end

        def relation_sql
          relation.to_sql
        end

        def touch_model_timestamps_unless(&block)
          return "" unless update_duplicates? && record_timestamps?

          model.timestamp_attributes_for_update_in_model.filter_map do |column_name|
            if touch_timestamp_attribute?(column_name)
              "#{column_name}=(CASE WHEN (#{updatable_columns.map(&block).join(" AND ")}) THEN #{model.quoted_table_name}.#{column_name} ELSE #{connection.high_precision_current_timestamp} END),"
            end
          end.join
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
end
