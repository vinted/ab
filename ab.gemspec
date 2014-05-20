# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ab/version'

Gem::Specification.new do |spec|
  spec.name = 'vinted-ab'
  spec.version = Ab::VERSION
  spec.authors = ['Mindaugas Mozūras', 'Gintaras Sakalauskas']
  spec.email = ['mindaugas.mozuras@gmail.com', 'gintaras.sakalauskas@gmail.com']
  spec.homepage = 'https://github.com/vinted/ab'
  spec.license = 'MIT'

  spec.files = `git ls-files`.split($/)
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
