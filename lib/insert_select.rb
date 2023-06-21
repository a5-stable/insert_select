# frozen_string_literal: true

require "active_record"

require_relative "insert_select/active_record"
require_relative "insert_select/errors"
require_relative "insert_select/version"

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.include(InsertSelect::ActiveRecord)
end
