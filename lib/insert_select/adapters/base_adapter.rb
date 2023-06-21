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
        into = builder.into

        if into.present?
          builder.reselect_relation!

          stmt = "INSERT #{into}"
          stmt += " #{builder.relation_sql}"
        else
          quoted_table_name = @connection.quote_table_name(table_name)
          stmt = "INSERT INTO #{quoted_table_name} #{builder.relation_sql}"
        end

        stmt
      end
    end
  end
end
