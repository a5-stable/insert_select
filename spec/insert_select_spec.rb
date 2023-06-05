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
      NewUser.insert_select_from(OldUser.all)
    end

    it "can select column which can be copied" do
      NewUser.insert_select_from(OldUser.select(:name).all)
    end

    it "can copy data with column mapping" do
      NewEmployee.insert_select_from(OldUser.all, mapping: {name: :full_name})
    end

    it "can specify constant value in mapping" do
      NewEmployee.insert_select_from(OldUser.all, mapping: {active: true})
    end

    it "can filter data by where clause" do
      NewUser.insert_select_from(OldUser.where("age > 20"))
    end
  end
end
