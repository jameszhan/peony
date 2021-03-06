# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'peony/version'

Gem::Specification.new do |spec|
  spec.name          = 'peony'
  spec.version       = Peony::VERSION
  spec.authors       = ['James Zhan']
  spec.email         = ['zhiqiangzhan@gmail.com']
  spec.description   = %q{Local Script Management System Using Rake}
  spec.summary       = %q{Local Script Management System Using Rake.}
  spec.homepage      = 'https://github.com/jameszhan/peony'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  
  spec.add_dependency 'rake', '~> 10.1'
  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rspec', '~> 2'
end
