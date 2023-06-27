module InsertSelect
  module Adapters
    class MysqlAdapter < BaseAdapter
      def initialize(table_name, connection)
        @table_name = table_name
        @connection = connection
      end

      def build_sql(builder)
        stmt = super

        if builder.on_duplicate == :skip
          stmt << " ON DUPLICATE KEY UPDATE `id`= VALUES(`id`) " 
        end

        stmt
      end
    end
  end
end
