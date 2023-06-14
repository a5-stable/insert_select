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

      expect(NewUserWithDifferentColumnName.count).to eq(6)
      expect(NewUserWithDifferentColumnName.pluck(:full_name)).to eq(["Dave", "Dee", "Dozy", "Beaky", "Mick", "Tich"])
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

    it "constant for exist column" do
      NewUserWithSameColumn.insert_select_from(OldUser, constant: {name: "Jerry"})

      expect(NewUserWithSameColumn.count).to eq(6)
      expect(NewUserWithSameColumn.pluck(:name)).to eq(Array.new(6, "Jerry"))
      expect(NewUserWithSameColumn.pluck(:age)).to eq([20, 30, 40, 50, 60, 70])
    end

    it "select & constant" do
      NewUserWithExtraColumn.insert_select_from(OldUser.select(:name), constant: {active: true})

      expect(NewUserWithExtraColumn.count).to eq(6)
      expect(NewUserWithExtraColumn.pluck(:name)).to eq(["Dave", "Dee", "Dozy", "Beaky", "Mick", "Tich"])
      expect(NewUserWithExtraColumn.pluck(:age)).to eq(Array.new(6, nil))
      expect(NewUserWithExtraColumn.pluck(:active)).to eq(Array.new(6, true))
    end

    it "constant has priority over select" do
      NewUserWithSameColumn.insert_select_from(OldUser.select(:name), constant: {name: "Jerry"})

      expect(NewUserWithSameColumn.count).to eq(6)
      expect(NewUserWithSameColumn.pluck(:name)).to eq(Array.new(6, "Jerry"))
      expect(NewUserWithSameColumn.pluck(:age)).to eq(Array.new(6, nil))
    end

    it "mapping & constant" do
      NewUserWithDifferentColumnName.insert_select_from(OldUser.all, mapping: {name: :full_name}, constant: {age: 30})

      expect(NewUserWithDifferentColumnName.count).to eq(6)
      expect(NewUserWithDifferentColumnName.pluck(:full_name)).to eq(["Dave", "Dee", "Dozy", "Beaky", "Mick", "Tich"])
      expect(NewUserWithDifferentColumnName.pluck(:age)).to eq(Array.new(6, 30))
    end

    it "mapping & select & constant" do
      NewUserWithDifferentColumn.insert_select_from(OldUser.select(:name), mapping: {name: :full_name}, constant: {active: 30})

      expect(NewUserWithDifferentColumn.count).to eq(6)
      expect(NewUserWithDifferentColumn.pluck(:full_name)).to eq(["Dave", "Dee", "Dozy", "Beaky", "Mick", "Tich"])
      expect(NewUserWithDifferentColumn.pluck(:email)).to eq(Array.new(6, nil))
      expect(NewUserWithDifferentColumn.pluck(:active)).to eq(Array.new(6, true))
    end

    it "can filter data by where clause" do
      NewUserWithSameColumn.insert_select_from(OldUser.where(age: 20))

      expect(NewUserWithSameColumn.count).to eq(1)
      expect(NewUserWithSameColumn.first.name).to eq("Dave")
      expect(NewUserWithSameColumn.first.age).to eq(20)
    end

    # it "raises error when a number of column is different" do
    #   expect { NewUserWithExtraColumn.insert_select_from(OldUser.all) }.to raise_error(InsertSelect::ColumnCountMisMatchError)
    # end

    # it "raises error when a number of column is different with select" do
    #   NewUserWithSameColumn.insert_select_from(NewUserWithExtraColumn.select(:name, :age, :active))
    # end

    # it "raises error when a type of column is different" do
    # end

    # it "raises error when a column does not exists in mapping" do
    # end
  end
end
