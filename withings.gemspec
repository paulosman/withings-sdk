# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'withings/version'

Gem::Specification.new do |spec|
  spec.name          = "withings"
  spec.version       = Withings::VERSION
  spec.authors       = ["Paul Osman"]
  spec.email         = ["paul@eval.ca"]

  spec.summary       = 'A Ruby interface to the Withings API.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/paulosman/withings'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "oauth", "~> 0.4"
  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
