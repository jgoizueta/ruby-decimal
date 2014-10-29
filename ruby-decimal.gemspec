# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'decimal/version'

Gem::Specification.new do |spec|
  spec.name          = "ruby-decimal"
  spec.version       = Decimal::DECIMAL_VERSION
  spec.authors       = ["Javier Goizueta"]
  spec.email         = ["jgoizueta@gmail.com"]
  spec.summary       = %q{Ruby Decimal Type}
  spec.description   = %q{Decimal type similar to Python's, following General Decimal Arithmetic Specification and IEEE 754-2008}
  spec.homepage      = "https://github.com/jgoizueta/ruby-decimal"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "flt", "~> 1.3.2"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
