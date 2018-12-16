# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'enkaironment/version'

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |spec|
  spec.name          = 'enkaironment'
  spec.version       = Enkaironment::VERSION
  spec.authors       = ['Kai Leahy']
  spec.email         = ['canhascodez@gmail.com']

  spec.summary       = 'a tool for setting up a Kai-approved development environment'
  spec.description   = 'The rule is, "If you\'re going to do it twice, script \
  it once, write tests, and package it as a gem". Pretty sure. This gem sets up \
  a development environment on a new machine. You might even want that!'
  spec.homepage      = 'https://github.com/tenebrousedge/enkaironment'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*.rb'] + Dir["bin/*"]
  spec.files        += Dir["[A-Z]*"] + Dir["spec/**/*"]
  spec.files        += Dir['config/locales/*.yml']
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.bindir        = 'bin'
  spec.executables   = 'enkaironment'
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'fakefs', '0.18.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-filesystem', '~> 1.2.0'
  spec.add_development_dependency 'mocha', '~> 1.7.0'
  spec.add_development_dependency 'pry', '~> 0.11.2'
  spec.add_development_dependency 'pry-byebug', '~> 3.6.0'
  spec.add_dependency 'git', '~> 1.5.0'
  spec.add_dependency 'highline', '~> 2.0.0'
  spec.add_dependency 'i18n', '~> 1.1.1'
  spec.add_dependency 'thor', '~> 0.20.3'
end
# rubocop:enable Metrics/BlockLength
