# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rolling_counter/version'

Gem::Specification.new do |spec|
  spec.name          = "rolling_counter"
  spec.version       = RollingCounter::Version
  spec.authors       = ["Mat Sadler", "Tim Blair"]
  spec.email         = ["mat@sourcetagsandcodes.com", "tim@bla.ir"]
  spec.description   = %q{A Redis-based multi-period rolling counter}
  spec.summary       = %q{A Redis-based multi-period rolling counter}
  spec.homepage      = "https://github.com/globaldev/rolling_counter"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "mock_redis"
  spec.add_development_dependency "timecop"
end
