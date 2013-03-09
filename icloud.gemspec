#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require File.expand_path("../lib/icloud/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "icloud"
  gem.version       = ICloud::VERSION

  gem.authors       = ["Adam Mckaig"]
  gem.email         = ["adam.mckaig@gmail.com"]
  gem.summary       = %q{Ruby library to read/write to Apple's iCloud}
  gem.homepage      = "https://github.com/adammck/ruby-icloud"

  gem.add_dependency "json_pure"
  gem.add_dependency "uuidtools"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
