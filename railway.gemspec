# frozen_string_literal: true

require_relative 'lib/railway/version'

Gem::Specification.new do |spec|
  spec.name        = 'railway'
  spec.version     = Railway::VERSION
  spec.date        = '2019-10-01'
  spec.summary     = 'British Train Information'
  spec.description = 'British Train Information'
  spec.authors     = ['Will Brown']
  spec.email       = 'mail@willbrown.name'
  spec.homepage    = 'https://www.github.com/rawls/railway'
  spec.license     = 'MIT'
  spec.files       = Dir['{bin,lib,config}/**/*', 'LICENSE', 'README.md']
  spec.test_files  = Dir['spec/**/*']
  spec.executables << 'railway'
  spec.add_runtime_dependency     'nokogiri',      '~> 1.10'
  spec.add_development_dependency 'byebug',        '~> 11.0'
  spec.add_development_dependency 'rack-test',     '~> 1.1'
  spec.add_development_dependency 'rspec',         '~> 3.8'
  spec.add_development_dependency 'rubocop',       '~> 0.68'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.36'
  spec.add_development_dependency 'simplecov',     '~> 0.17'
  spec.add_development_dependency 'sinatra',       '~> 2.0'
  spec.add_development_dependency 'webmock',       '~> 3.7'
end
