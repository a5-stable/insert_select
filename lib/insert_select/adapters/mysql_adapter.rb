module InsertSelect
  module Adapters
    class MysqlAdapter < BaseAdapter
      def initialize(connection)
        @connection = connection
      end

      def insert_select_from(relation, options = {})
        super
      end
    end
  end
end
