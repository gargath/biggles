# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'biggles/version'

Gem::Specification.new do |spec|
  spec.name          = 'biggles'
  spec.version       = Biggles::VERSION
  spec.authors       = ['gargath']
  spec.email         = ['signup@lightweaver.info']

  spec.summary       = 'Awesome Gem'
  spec.description   = "It's a really awesome gem"
  spec.homepage      = 'http://example.com'
  spec.license       = 'LGPL-3.0'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '0.49.0'
  spec.add_development_dependency 'otr-activerecord', '1.2.1'
  spec.add_development_dependency 'sqlite3', '~> 1.3'
  spec.add_development_dependency 'simplecov', '~> 0'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 1.0', '>= 1.0.0'

  spec.add_runtime_dependency 'activerecord', '~> 5'
  spec.add_runtime_dependency 'require_all', '1.4.0'
  spec.add_runtime_dependency 'concurrent-ruby', '1.0.5'
end
