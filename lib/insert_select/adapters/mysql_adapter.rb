module InsertSelect
  module Adapters
    class MysqlAdapter < BaseAdapter
      def initialize(connection)
        @connection = connection
      end

      def insert_select(relation)
        
      end
    end
  end
end
