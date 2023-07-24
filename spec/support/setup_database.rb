database_yml = File.expand_path("database.yml", __dir__)
configs = YAML.load_file(database_yml)
ActiveRecord::Base.configurations = configs
ActiveRecord::Base.establish_connection(ENV["ADAPTER_NAME"]&.to_sym || :sqlite3)

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

def prepare_data
  data = [
    {name: "Dave", age: 20},
    {name: "Dee", age: 30},
    {name: "Dozy", age: 40},
    {name: "Beaky", age: 50},
    {name: "Mick", age: 60},
    {name: "Tich", age: 70},
  ]

  OldUser.insert_all(data)
end

prepare_data
