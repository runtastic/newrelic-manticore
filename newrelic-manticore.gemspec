# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "newrelic/manticore/version"

Gem::Specification.new do |gem|
  gem.name          = "newrelic-manticore"
  gem.version       = Newrelic::Manticore::VERSION
  gem.authors       = ["Dominik Goltermann",
                       "Alexander Junger"]

  gem.email         = ["dominik.goltermann@runtastic.com",
                       "alexander.junger@runtastic.com"]

  gem.summary       = "Newrelic support for manticore"
  gem.description   = "Adds manticore tracking for HTTP calls and Elasticsearch to Newrelic"
  gem.homepage      = "http://github.com/runtastic/newrelic-manticore"

  gem.platform      = "java"
  gem.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  gem.bindir        = "exe"
  gem.executables   = gem.files.grep(%r{^exe/}) { |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_development_dependency "bundler", "~> 1.13"
  gem.add_development_dependency "pry", "~> 0"
  gem.add_development_dependency "rake", "~> 10.0"
  gem.add_development_dependency "rspec", "~> 3.0"
  gem.add_development_dependency "rt_rubocop_defaults", "~> 1"
  gem.add_development_dependency "rubocop_runner", "~> 2"
end
