# frozen_string_literal: true

require_relative "lib/heal/version"

Gem::Specification.new do |spec|
  spec.name = "heal"
  spec.version = Heal::VERSION
  spec.authors = ["Jatin Goyal"]
  spec.email = ["jjatinggoyal@gmail.com"]

  spec.summary = "Heal your dev workflows"
  spec.homepage = "https://github.com/jjatinggoyal/heal"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.executables = %w[ heal ]
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 1.0"
  spec.add_dependency "tty-prompt", "~> 0.23.1"
  spec.add_dependency "zeitwerk", ">= 2.6.18", "< 3.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
