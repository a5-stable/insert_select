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
          InsertSelect::ActiveRecord::InsertSelectFrom.new(self, relation, mapping: options[:mapping], constant: options[:constant], returning: nil, record_timestamps: nil).execute
        end
      end
    end

    class InsertSelectFrom
      attr_reader :model, :connection, :relation, :adapter, :mapping, :constant, :returning, :record_timestamps

      def initialize(model, relation, mapping:, constant:, returning:, record_timestamps:)
        @model = model
        @connection = model.connection
        @relation = relation
        @adapter = find_adapter(connection)
        @mapping = mapping
        @constant = constant
        @returning = returning
        @record_timestamps = record_timestamps
      end

      def to_sql
        adapter.build_sql(Builder.new(self))
      end

      def execute
        connection.execute(to_sql)
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
        attr_reader :relation, :constant, :mapping, :returning, :record_timestamps

        def initialize(insert_select_from)
          @relation = insert_select_from.relation.all
          @constant = insert_select_from.constant || {}
          @mapping = insert_select_from.mapping || {}
          @returning = insert_select_from.returning
          @record_timestamps = insert_select_from.record_timestamps
          @connection = insert_select_from.connection
        end

        def mapper
          result = {}
          insert_mapping = mapping.transform_keys(&:to_s)
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

          constant_mapping = {}
          if insert_mapping.blank?
            @connection.columns(relation.table_name).map{|c|
              insert_mapping[c.name.to_s] = c.name
            }
          end

          constant.each {|k, v|
            insert_mapping.delete(k.to_s)
            relation.select_values = relation.select_values - [k.to_sym]
            constant_mapping[k.to_s] = "\"#{v}\""
          }

          result[:insert_mapping] = insert_mapping
          result[:constant_mapping] = constant_mapping

          result
        end

        # def insert_mapping
        #   res = mapping.transform_keys(&:to_s)
        #   mapping_column_names = mapping.keys

        #   if selected_column_names.present?
        #     selected_column_names.each do |column_name|
        #       if mapping[column_name]
        #         res[column_name.to_s] = mapping[column_name]
        #         mapping_column_names.delete(column_name)
        #       else
        #         res[column_name.to_s] = column_name
        #       end
        #     end
        #   end

        #   if mapping_column_names.present?
        #     @connection.columns(relation.table_name).map{|c|
        #       res[c.name.to_s] = mapping[c.name.to_sym] || c.name
        #     }
        #   end

        #   res
        # end

        # def constant_mapping
        #   res = {}
        #   insert_mapping = insert_mapping || {}
        #   if insert_mapping.blank?
        #     @connection.columns(relation.table_name).map{|c|
        #       insert_mapping[c.name.to_s] = c.name
        #     }
        #   end

        #   constant.each {|k, v|
        #     insert_mapping.delete(k.to_s)
        #     relation.select_values = relation.select_values - [k.to_sym]
        #     res[k.to_s] = "\"#{v}\""
        #   }

        #   res
        # end

        def selected_column_names
          relation.select_values
        end

        private

      end
    end
  end
end
