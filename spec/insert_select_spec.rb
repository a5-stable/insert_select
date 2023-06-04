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
  end

  describe "with where condition" do
  end
end
