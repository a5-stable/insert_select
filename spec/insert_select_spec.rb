# frozen_string_literal: true

RSpec.describe InsertSelect do
  def setup
    FastCount.install
    @connection = ActiveRecord::Base.connection
    @connection.schema_cache.clear!
  end

  def teardown
    FastCount.uninstall
    User.delete_all
  end

  describe "without where condition" do
    # INSERT INTO dynamic_tables (column1, column2, column3, ...)
    # SELECT dynamic_tables_1.column1, dynamic_tables_1.column2, dynamic_tables_1.column3, ...
    # FROM dynamic_tables_1
    # WHERE created_at > '2022-01-01'
    # DynamicTable.insert_select(DynamicTable1.where("created_at > ?", "2022-01-01")).only(:column1, :column2, :column3)
  end

  describe "with where condition" do
  end
end
