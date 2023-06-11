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
    it "can copy all data with class" do
      NewUserWithSameColumn.insert_select_from(OldUser)

      expect(NewUserWithSameColumn.count).to eq(6)
    end

    it "only select" do
      NewUserWithSameColumn.insert_select_from(OldUser.select(:name).all)

      expect(NewUserWithSameColumn.count).to eq(6)
      expect(NewUserWithSameColumn.pluck(:name)).to eq(["Dave", "Dee", "Dozy", "Beaky", "Mick", "Tich"])
      expect(NewUserWithSameColumn.pluck(:age)).to eq(Array.new(6, nil))
    end

    it "only mapping" do
      NewUserWithDifferentColumnName.insert_select_from(OldUser, mapping: {name: :full_name})

      expect(NewUserWithSameColumn.count).to eq(6)
    end

    it "select & mapping" do
      NewUserWithDifferentColumnName.insert_select_from(OldUser.select(:name).all, mapping: {name: :full_name})

      expect(NewUserWithDifferentColumnName.count).to eq(6)
      expect(NewUserWithDifferentColumnName.pluck(:full_name)).to eq(["Dave", "Dee", "Dozy", "Beaky", "Mick", "Tich"])
      expect(NewUserWithDifferentColumnName.pluck(:age)).to eq(Array.new(6, nil))
    end

    it "only constant" do
      NewUserWithExtraColumn.insert_select_from(OldUser, constant: {active: true})

      expect(NewUserWithExtraColumn.count).to eq(6)
      expect(NewUserWithExtraColumn.pluck(:name)).to eq(["Dave", "Dee", "Dozy", "Beaky", "Mick", "Tich"])
      expect(NewUserWithExtraColumn.pluck(:age)).to eq([20, 30, 40, 50, 60, 70])
      expect(NewUserWithExtraColumn.pluck(:active)).to eq(Array.new(6, true))
    end

    it "select & constant" do
      NewUserWithExtraColumn.insert_select_from(OldUser.select(:name), constant: {active: true})

      expect(NewUserWithExtraColumn.count).to eq(6)
      expect(NewUserWithExtraColumn.pluck(:name)).to eq(["Dave", "Dee", "Dozy", "Beaky", "Mick", "Tich"])
      expect(NewUserWithExtraColumn.pluck(:age)).to eq(Array.new(6, nil))
      expect(NewUserWithExtraColumn.pluck(:active)).to eq(Array.new(6, true))
    end

    it "mapping & constant" do
      NewUserWithDifferentColumnName.insert_select_from(OldUser.all, mapping: {name: :full_name}, constant: {age: 30})
      binding.irb
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
