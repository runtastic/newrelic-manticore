# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "newrelic/manticore/version"

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |gem|
  gem.name          = "newrelic-manticore"
  gem.version       = Newrelic::Manticore::VERSION
  gem.authors       = ["Dominik Goltermann",
                       "Alexander Junger"]

  gem.email         = ["dominik.goltermann@runtastic.com",
                       "alexander.junger@runtastic.com"]

  gem.summary       = "Newrelic support for manticore"
  gem.description   = "Adds manticore tracking for HTTP calls to Newrelic"
  gem.homepage      = "http://github.com/runtastic/newrelic-manticore"
  gem.license       = "MIT"

  gem.platform      = "java"
  gem.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  gem.bindir        = "exe"
  gem.executables   = gem.files.grep(%r{^exe/}) { |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.0.0"

  gem.add_runtime_dependency     "manticore", "~> 0.9"
  gem.add_runtime_dependency     "newrelic_rpm", ">= 8", "< 9"

  gem.add_development_dependency "bundler"
  gem.add_development_dependency "faraday", "~> 0"
  gem.add_development_dependency "minitest"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "rake", "~> 12.3", ">= 12.3.3"
  gem.add_development_dependency "rspec", "~> 3.0"
  gem.add_development_dependency "rt_rubocop_defaults", "~> 1"
  gem.add_development_dependency "rubocop_runner", "~> 2"
end
# rubocop:enable Metrics/BlockLength
