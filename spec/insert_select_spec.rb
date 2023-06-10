# frozen_string_literal: true

RSpec.describe InsertSelect do
  def setup
    @connection = ActiveRecord::Base.connection
    @connection.schema_cache.clear!
  end

  def teardown
  end

  describe "select insert" do
    it "can copy all data from old_users to new_users" do
      NewUser.insert_select_from(OldUser)
    end

    it "can select column which can be copied" do
      NewUser.insert_select_from(OldUser.select(:name).all)
    end

    it "can copy data with column mapping" do
      NewEmployee.insert_select_from(OldUser.select(:name).all, mapping: {full_name: :name, active: true})
    end

    it "can specify constant value in mapping" do
      NewEmployee.insert_select_from(OldUser.select(:name).all, mapping: {full_name: :name, active: true})
    end

    it "can filter data by where clause" do
      NewUser.insert_select_from(OldUser.where("age > 20"))
    end

    it "raises error when a number of column is different" do
      NewEmployee.insert_select_from(OldUser.all)
    end

    it "raises error when a number of column is different with select" do
      NewEmployee.insert_select_from(OldUser.select(:name, :age).all)
    end

    it "raises error when a type of column is different" do
    end

    it "raises error when a column does not exists in mapping" do
    end
  end
end
