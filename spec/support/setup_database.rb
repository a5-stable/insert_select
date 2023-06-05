ActiveRecord::Base.configurations = {'test' => {adapter: 'sqlite3', database: ':memory:'}}
ActiveRecord::Base.establish_connection :test

class CreateAllTables < ActiveRecord::Migration[7.0]
  def self.up
    create_table(:old_users) do |t|
      t.string :name
      t.integer :age
    end

    create_table(:new_users) do |t|
      t.string :name
      t.integer :age
    end

    create_table(:new_employee) do |t|
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

class NewUser < ActiveRecord::Base
end

class NewEmployee < ActiveRecord::Base
end
