# frozen_string_literal: true

RSpec.describe InsertSelect do
  def setup
    @connection = ActiveRecord::Base.connection
    @connection.schema_cache.clear!
  end

  def teardown
  end

  describe "without where condition" do
    binding.irb
    User.create!
    User.create!

    DupUser.insert_select_from(User.all.select(:name))
  end

  describe "with where condition" do
  end
end
