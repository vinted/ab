# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ab/version'

Gem::Specification.new do |spec|
  spec.name = 'vinted-ab'
  spec.version = Ab::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.authors = ['Mindaugas Mozūras', 'Gintaras Sakalauskas']
  spec.email = ['mindaugas.mozuras@gmail.com', 'gintaras.sakalauskas@gmail.com']
  spec.homepage = 'https://github.com/vinted/ab'
  spec.summary = 'AB testing gem used internally by Vinted'

  spec.required_rubygems_version = '>= 1.3.6'
  spec.license = 'MIT'

  spec.files = `git ls-files`.split($/)
  spec.test_files = `git ls-files -- {spec}/*`.split("\n")
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.1', '>= 10.1.0'
  spec.add_development_dependency 'rspec', '~> 2.14', '>= 2.14.0'
  spec.add_development_dependency 'rspec-its', '~> 1.0.1'
  spec.add_development_dependency 'json-schema', '~> 2.2.2', '>= 2.2.2'
  spec.add_development_dependency 'ruby-prof', '~> 0.15.0', '>= 0.15.0'
  spec.add_development_dependency 'pry', '~> 0.10.0', '>= 0.10.0'
end
