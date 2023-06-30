# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

namespace :spec do
  ["postgresql", "mysql2", "sqlite3"].each do |adapter|
    RSpec::Core::RakeTask.new(adapter) do |t|
      ENV["ADAPTER_NAME"] = adapter 
      ENV["DATABASE_NAME"] = adapter == "sqlite3" ? ":memory:" : "insert_select_test"
      t.pattern = FileList["spec/*_spec.rb"]
    end
  end
end

task spec: ["spec:postgresql", "spec:mysql2", "spec:sqlite3"]
task default: :spec
