# frozen_string_literal: true

RSpec.describe InsertSelect do
  def setup
    @connection = ActiveRecord::Base.connection
    @connection.schema_cache.clear!
  end

  def teardown
  end

  # create_table(:old_users) do |t|
  #   t.string :name
  #   t.integer :age
  # end

  # create_table(:new_users_with_same_columns) do |t|
  #   t.string :name
  #   t.integer :age
  # end

  # create_table(:new_users_with_extra_columns) do |t|
  #   t.string :name
  #   t.integer :age
  #   t.boolean :active
  # end

  # create_table(:new_users_with_different_column_names) do |t|
  #   t.string :full_name
  #   t.integer :age
  # end

  # create_table(:new_users_with_different_columns) do |t|
  #   t.string :full_name
  #   t.string :email
  #   t.boolean :active
  # end

  describe "select insert" do
    it "can copy all data with class" do
      NewUserWithSameColumn.insert_select_from(OldUser)
    end

    it "only select" do
      NewUserWithSameColumn.insert_select_from(OldUser.select(:name).all)
    end

    it "only mapping" do
      NewUserWithDifferentColumnName.insert_select_from(OldUser, mapping: {name: :full_name})
    end

    it "select & mapping" do
      NewUserWithDifferentColumnName.insert_select_from(OldUser.select(:name).all, mapping: {name: :full_name})
    end

    it "only constant" do
      NewUserWithExtraColumn.insert_select_from(OldUser, constant: {active: true})
    end

    it "select & constant" do
      NewEmployee.insert_select_from(OldUser.select(:name).all)
    end

    it "mapping & constant" do
      NewEmployee.insert_select_from(OldUser.select(:name).all)
    end

    it "mapping & select & constant" do
      NewEmployee.insert_select_from(OldUser.select(:name).all)
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
