# frozen_string_literal: true

require_relative "lib/tty-draft"

Gem::Specification.new do |spec|
  spec.name = "tty-draft"
  spec.version = TTY::Draft::VERSION
  spec.authors = ["c"]
  spec.email = ["0xe0ffff@gmail.com"]

  spec.summary = "Just like `TTY::Prompt#multiline` but let you move cursor around to edit before submission."
  spec.homepage = "https://github.com/kill-2/tty-draft"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "tty-reader", "~> 0.9.0"
  spec.add_dependency "tty-live", "~> 0.1.1"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
