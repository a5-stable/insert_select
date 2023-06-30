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
      expect(NewUserWithDifferentColumnName.pluck(:age)).to eq([20, 30, 40, 50, 60, 70])
    end

    it "can copy data with different column name by mapping with select clause" do
      NewUserWithDifferentColumnName.insert_select_from(OldUser.select(:name).all, mapping: {name: :full_name})

      expect(NewUserWithDifferentColumnName.count).to eq(6)
      expect(NewUserWithDifferentColumnName.pluck(:full_name)).to eq(["Dave", "Dee", "Dozy", "Beaky", "Mick", "Tich"])
      expect(NewUserWithDifferentColumnName.pluck(:age)).to eq(Array.new(6, nil))
    end

    it "can copy data with constant value" do
      NewUserWithExtraColumn.create_with(active: true).insert_select_from(OldUser)

      expect(NewUserWithExtraColumn.count).to eq(6)
      expect(NewUserWithExtraColumn.pluck(:name)).to eq(["Dave", "Dee", "Dozy", "Beaky", "Mick", "Tich"])
      expect(NewUserWithExtraColumn.pluck(:age)).to eq([20, 30, 40, 50, 60, 70])
      expect(NewUserWithExtraColumn.pluck(:active)).to eq(Array.new(6, true))
    end

    it "can overwrite data with constant value" do
      NewUserWithSameColumn.create_with(name: "Jerry").insert_select_from(OldUser)

      expect(NewUserWithSameColumn.count).to eq(6)
      expect(NewUserWithSameColumn.pluck(:name)).to eq(Array.new(6, "Jerry"))
      expect(NewUserWithSameColumn.pluck(:age)).to eq([20, 30, 40, 50, 60, 70])
    end

    it "can copy data with constant value and select clause" do
      NewUserWithExtraColumn.create_with(active: true).insert_select_from(OldUser.select(:name))

      expect(NewUserWithExtraColumn.count).to eq(6)
      expect(NewUserWithExtraColumn.pluck(:name)).to eq(["Dave", "Dee", "Dozy", "Beaky", "Mick", "Tich"])
      expect(NewUserWithExtraColumn.pluck(:age)).to eq(Array.new(6, nil))
      expect(NewUserWithExtraColumn.pluck(:active)).to eq(Array.new(6, true))
    end

    it "can copy data with constant value" do
      NewUserWithSameColumn.create_with(name: "Jerry").insert_select_from(OldUser.select(:name))

      expect(NewUserWithSameColumn.count).to eq(6)
      expect(NewUserWithSameColumn.pluck(:name)).to eq(Array.new(6, "Jerry"))
      expect(NewUserWithSameColumn.pluck(:age)).to eq(Array.new(6, nil))
    end

    it "can copy data with constant value and mapping" do
      NewUserWithDifferentColumnName.create_with(age: 30).insert_select_from(OldUser.all, mapping: {name: :full_name})

      expect(NewUserWithDifferentColumnName.count).to eq(6)
      expect(NewUserWithDifferentColumnName.pluck(:full_name)).to eq(["Dave", "Dee", "Dozy", "Beaky", "Mick", "Tich"])
      expect(NewUserWithDifferentColumnName.pluck(:age)).to eq(Array.new(6, 30))
    end

    it "can copy data with constant value, mapping and select clause" do
      NewUserWithDifferentColumn.create_with(active: true).insert_select_from(OldUser.select(:name), mapping: {name: :full_name})

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

    it "can use returning specification" do
      skip "returning not supported" unless ActiveRecord::Base.connection.supports_insert_returning?

      res = NewUserWithSameColumn.insert_select_from(OldUser, returning: %i[id name])
      puts res
      expect(res.pluck("id")).to eq([1, 2, 3, 4, 5, 6])
      expect(res.pluck("name")).to eq(["Dave", "Dee", "Dozy", "Beaky", "Mick", "Tich"])
    end

    it "can skip duplicate data with not bang method " do
      expect { OldUser.insert_select_from(OldUser) }.not_to raise_error
      expect { OldUser.insert_select_from(OldUser.where(age: 20)) }.not_to raise_error # with where clause
      expect { OldUser.insert_select_from(OldUser.limit(5)) }.not_to raise_error # wirh limit clause

      expect { OldUser.insert_select_from!(OldUser) }.to raise_error(ActiveRecord::RecordNotUnique)
      expect { OldUser.insert_select_from!(OldUser.where(age: 20)) }.to raise_error(ActiveRecord::RecordNotUnique) # with where clause
      expect { OldUser.insert_select_from!(OldUser.limit(5)) }.to raise_error(ActiveRecord::RecordNotUnique) # wirh limit clause
    end
  end
end
