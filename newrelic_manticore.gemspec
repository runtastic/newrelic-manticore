# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "newrelic_manticore/version"

Gem::Specification.new do |spec|
  spec.name          = "newrelic_manticore"
  spec.version       = NewrelicManticore::VERSION
  spec.authors       = ["Dominik Goltermann"]
  spec.email         = ["dominik.goltermann@runtastic.com"]

  spec.summary       = "Newrelic support for manticore"
  spec.description   = "Adds manticore tracking for HTTP calls and Elasticsearch to Newrelic"
  spec.homepage      = "http://gems.runtastic.com"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "http://gems.runtastic.com"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "pry", "~> 0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rt_rubocop_defaults", "~> 1"
  spec.add_development_dependency "rubocop_runner", "~> 2"
end
