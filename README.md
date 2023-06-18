# InsertSelect
[![Ruby](https://github.com/a5-stable/insert_select/actions/workflows/ruby.yml/badge.svg)](https://github.com/a5-stable/insert_select/actions/workflows/ruby.yml)
![Code Climate](https://codeclimate.com/github/a5-stable/insert_select.png)

This is a custom gem that extends ActiveRecord to enable the expression of SQL `INSERT INTO ... SELECT ...` queries in a more convenient way. It allows you to copy data from one table to another based on specified conditions using a simple and expressive syntax.

SQL example of `INSERT INTO ... SELECT ...`:
```
INSERT INTO films SELECT * FROM tmp_films WHERE date_prod < '2004-05-07';
```

documentation:
- MySQL: https://dev.mysql.com/doc/refman/8.0/en/insert-select.html
- PostgreSQL: https://www.postgresql.org/docs/current/sql-insert.html

## Installation

Add this line to your Gemfile:  

```ruby
gem 'insert_select'
```
  
And then execute:
```ruby
bundle install
```
  
Or install it yourself as:
```ruby
gem install insert_select
```
  
## Usage

### Copy all data from OldUser to NewUser

```ruby
NewUser.insert_select_from(OldUser)

#=> INSERT INTO "new_users" SELECT "old_users".* FROM "old_users"
```

### Filter the columns to be copied

```ruby
NewUser.insert_select_from(OldUser.select(:name))

#=> INSERT INTO "new_users" ("name") SELECT "old_users"."name" FROM "old_users"
```

### Copy data between different column names

You can specify column name mappings between tables.
```ruby
AnotherUser.insert_select_from(OldUser, mapping: { old_name: :another_name })

#=> INSERT INTO "another_users" ("another_name") SELECT "old_users"."name" FROM "old_users"
```

### Set a constant value
```ruby
AnotherUser.insert_select_from(OldUser, mapping: { old_name: :another_name }, constant: { another_constant_column: "20" })

#=> INSERT INTO "another_users" ("another_name", "another_constant_column") SELECT "old_users"."name", "20" FROM "old_users"
```

### Use a WHERE clause to filter the data
```ruby
NewUser.insert_select_from(OldUser.where("age > ?", 20))

#=> INSERT INTO "new_users" SELECT "old_users".*, FROM "old_users" WHERE ("age" > 20)
```

### Use the RETURNING clause (only for PostgreSQL connection)
```ruby
NewUser.insert_select_from(OldUser, returning: [:id])

#=> INSERT INTO "new_users" SELECT "old_users".* FROM "old_users" RETURNING "id"
```

Other options, which are enabled in [`insert_all`](https://www.rubydoc.info/github/rails/rails/ActiveRecord%2FPersistence%2FClassMethods:insert_all) should be also supported, but are not yet implemented.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/a5-stable/insert_select. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/a5-stable/insert_select/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the InsertSelect project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/a5-stable/insert_select/blob/main/CODE_OF_CONDUCT.md).
