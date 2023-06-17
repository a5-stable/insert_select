# frozen_string_literal: true

RSpec.describe InsertSelect do
  def setup
    @connection = ActiveRecord::Base.connection
    @connection.schema_cache.clear!
  end

  after(:each) do
    NewUserWithDifferentColumn.delete_all
    NewUserWithDifferentColumnName.delete_all
    NewUserWithExtraColumn.delete_all
    NewUserWithSameColumn.delete_all
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
    it "can copy all data with class name" do
      NewUserWithSameColumn.insert_select_from(OldUser)

      expect(NewUserWithSameColumn.count).to eq(6)
    end

    it "can select specific columns to be copied" do
      NewUserWithSameColumn.insert_select_from(OldUser.select(:name).all)

      expect(NewUserWithSameColumn.count).to eq(6)
      expect(NewUserWithSameColumn.pluck(:name)).to eq(["Dave", "Dee", "Dozy", "Beaky", "Mick", "Tich"])
      expect(NewUserWithSameColumn.pluck(:age)).to eq(Array.new(6, nil))
    end

    it "can exclude specific columns to be copied by using except" do
      NewUserWithSameColumn.insert_select_from(OldUser.except(:id).all)
      NewUserWithSameColumn.insert_select_from(OldUser.except(:id).all) # not raise error because id is not unique

      expect(NewUserWithSameColumn.count).to eq(12)
    end

    it "can copy data with different column name by mapping" do
      NewUserWithDifferentColumnName.insert_select_from(OldUser, mapping: {name: :full_name})

      expect(NewUserWithDifferentColumnName.count).to eq(6)
      expect(NewUserWithDifferentColumnName.pluck(:full_name)).to eq(["Dave", "Dee", "Dozy", "Beaky", "Mick", "Tich"])
    end

    it "can copy data with different column name by mapping with select clause" do
      NewUserWithDifferentColumnName.insert_select_from(OldUser.select(:name).all, mapping: {name: :full_name})

      expect(NewUserWithDifferentColumnName.count).to eq(6)
      expect(NewUserWithDifferentColumnName.pluck(:full_name)).to eq(["Dave", "Dee", "Dozy", "Beaky", "Mick", "Tich"])
      expect(NewUserWithDifferentColumnName.pluck(:age)).to eq(Array.new(6, nil))
    end

    it "can copy data with constant value" do
      NewUserWithExtraColumn.insert_select_from(OldUser, constant: {active: true})

      expect(NewUserWithExtraColumn.count).to eq(6)
      expect(NewUserWithExtraColumn.pluck(:name)).to eq(["Dave", "Dee", "Dozy", "Beaky", "Mick", "Tich"])
      expect(NewUserWithExtraColumn.pluck(:age)).to eq([20, 30, 40, 50, 60, 70])
      expect(NewUserWithExtraColumn.pluck(:active)).to eq(Array.new(6, true))
    end

    it "can overwrite data with constant value" do
      NewUserWithSameColumn.insert_select_from(OldUser, constant: {name: "Jerry"})

      expect(NewUserWithSameColumn.count).to eq(6)
      expect(NewUserWithSameColumn.pluck(:name)).to eq(Array.new(6, "Jerry"))
      expect(NewUserWithSameColumn.pluck(:age)).to eq([20, 30, 40, 50, 60, 70])
    end

    it "can copy data with constant value and select clause" do
      NewUserWithExtraColumn.insert_select_from(OldUser.select(:name), constant: {active: true})

      expect(NewUserWithExtraColumn.count).to eq(6)
      expect(NewUserWithExtraColumn.pluck(:name)).to eq(["Dave", "Dee", "Dozy", "Beaky", "Mick", "Tich"])
      expect(NewUserWithExtraColumn.pluck(:age)).to eq(Array.new(6, nil))
      expect(NewUserWithExtraColumn.pluck(:active)).to eq(Array.new(6, true))
    end

    it "can copy data with constant value" do
      NewUserWithSameColumn.insert_select_from(OldUser.select(:name), constant: {name: "Jerry"})

      expect(NewUserWithSameColumn.count).to eq(6)
      expect(NewUserWithSameColumn.pluck(:name)).to eq(Array.new(6, "Jerry"))
      expect(NewUserWithSameColumn.pluck(:age)).to eq(Array.new(6, nil))
    end

    it "can copy data with constant value and mapping" do
      NewUserWithDifferentColumnName.insert_select_from(OldUser.all, mapping: {name: :full_name}, constant: {age: 30})

      expect(NewUserWithDifferentColumnName.count).to eq(6)
      expect(NewUserWithDifferentColumnName.pluck(:full_name)).to eq(["Dave", "Dee", "Dozy", "Beaky", "Mick", "Tich"])
      expect(NewUserWithDifferentColumnName.pluck(:age)).to eq(Array.new(6, 30))
    end

    it "can copy data with constant value, mapping and select clause" do
      NewUserWithDifferentColumn.insert_select_from(OldUser.select(:name), mapping: {name: :full_name}, constant: {active: 30})

      expect(NewUserWithDifferentColumn.count).to eq(6)
      expect(NewUserWithDifferentColumn.pluck(:full_name)).to eq(["Dave", "Dee", "Dozy", "Beaky", "Mick", "Tich"])
      expect(NewUserWithDifferentColumn.pluck(:email)).to eq(Array.new(6, nil))
      expect(NewUserWithDifferentColumn.pluck(:active)).to eq(Array.new(6, true))
    end

    it "can filter data to be copied by where clause" do
      NewUserWithSameColumn.insert_select_from(OldUser.where(age: 20))

      expect(NewUserWithSameColumn.count).to eq(1)
      expect(NewUserWithSameColumn.first.name).to eq("Dave")
      expect(NewUserWithSameColumn.first.age).to eq(20)
    end
  end
end
