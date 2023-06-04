# frozen_string_literal: true

require "active_record"

require_relative "insert_select/active_record"
require_relative "insert_select/version"

module InsertSelect
  class Error < StandardError; end
  # Your code goes here...
end

ActiveSupport.on_load(:active_record) do
  extend InsertSelect::ActiveRecord
  ActiveRecord::Base.include(InsertSelect::ActiveRecord)
end
