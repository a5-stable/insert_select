ActiveRecord::Base.configurations = {'test' => {adapter: 'sqlite3', database: ':memory:'}}
ActiveRecord::Base.establish_connection :test

class CreateAllTables < ActiveRecord::Migration[7.0]
  def self.up
    create_table(:old_users) do |t|
      t.string :name
      t.integer :age
    end

    create_table(:new_user_with_same_columns) do |t|
      t.string :name
      t.integer :age
    end

    create_table(:new_user_with_different_column_names) do |t|
      t.string :full_name
      t.integer :age
    end

    create_table(:new_user_with_extra_columns) do |t|
      t.string :name
      t.integer :age
      t.boolean :active
    end

    create_table(:new_user_with_different_columns) do |t|
      t.string :full_name
      t.string :email
      t.boolean :active
    end
  end
end

ActiveRecord::Migration.verbose = false
CreateAllTables.up

class OldUser < ActiveRecord::Base
end

class NewUserWithSameColumn < ActiveRecord::Base
end

class NewUserWithExtraColumn < ActiveRecord::Base
end

class NewUserWithDifferentColumnName < ActiveRecord::Base
end

class NewUserWithDifferentColumn < ActiveRecord::Base
end
