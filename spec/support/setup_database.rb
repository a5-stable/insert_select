ActiveRecord::Base.configurations = {'test' => {adapter: 'sqlite3', database: ':memory:'}}
ActiveRecord::Base.establish_connection :test

class CreateAllTables < ActiveRecord::Migration[7.0]
  def self.up
    create_table(:users) do |t|
      t.string :name
      t.integer :age
    end

    create_table(:dup_users) do |t|
      t.string :name
      t.integer :age
    end
  end
end

ActiveRecord::Migration.verbose = false
CreateAllTables.up

class User < ActiveRecord::Base
end

class DupUser < ActiveRecord::Base
end
