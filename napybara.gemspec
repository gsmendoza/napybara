# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'napybara/version'

Gem::Specification.new do |spec|
  spec.name          = "napybara"
  spec.version       = Napybara::VERSION
  spec.authors       = ["George Mendoza"]
  spec.email         = ["gsmendoza@gmail.com"]
  spec.summary       = %q{napybara == nested capybara}
  spec.description   = %q{DSL for nesting capybara helpers}
  spec.homepage      = "https://github.com/gsmendoza/napybara"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "capybara"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "fuubar"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "overcommit"
  spec.add_development_dependency "poltergeist"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14.0"
  spec.add_development_dependency "rspec-example_steps"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "sinatra"
end
