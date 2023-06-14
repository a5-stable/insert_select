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
        insert_mapping = builder.insert_mapping
        constant_mapping = builder.constant_mapping
        quoted_table_name = @connection.quote_table_name(table_name)
        into = builder.into
        relation_sql = builder.relation_sql

        if into.present?
          stmt = "INSERT #{into}"
          stmt += " #{relation_sql}"
        else
          stmt = "INSERT INTO #{quoted_table_name} #{relation_sql}"
        end

        stmt
      end
    end
  end
end
