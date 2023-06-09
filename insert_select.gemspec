# frozen_string_literal: true

require_relative "lib/insert_select/version"

Gem::Specification.new do |spec|
  spec.name = "insert_select"
  spec.version = InsertSelect::VERSION
  spec.authors = ["a5-stable"]
  spec.email = ["sh07e1916@gmail.com"]

  spec.summary = "Gem for performing simple data copying using SQL `INSERT INTO ... SELECT ...` queries"
  spec.description = "This is a custom gem that extends ActiveRecord to enable the expression of SQL `INSERT INTO ... SELECT ...` queries in a more convenient way. It allows you to copy data from one table to another based on specified conditions using a simple and expressive syntax."
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = "https://github.com/a5-stable/insert_select"
  spec.metadata["source_code_uri"] = "https://github.com/a5-stable/insert_select"
  spec.metadata["changelog_uri"] = "https://github.com/a5-stable/insert_select/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord"
end
