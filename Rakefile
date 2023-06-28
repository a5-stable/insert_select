# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task spec: ["spec:mysql2", "spec:postgresql", "spec:sqlite3"]
task default: [:spec]
