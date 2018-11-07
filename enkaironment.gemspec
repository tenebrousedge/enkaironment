lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'enkaironment/version'

Gem::Specification.new do |spec|
  spec.name          = 'enkaironment'
  spec.version       = Enkaironment::VERSION
  spec.authors       = ['Kai Leahy']
  spec.email         = ['canhascodez@gmail.com']

  spec.summary       = 'Rake tasks for setting up a Kai-approved development environment'
  spec.description   = 'The rule is, "If you\'re going to do it twice, script \
  it once, write tests, and package it as a gem". Pretty sure. This gem sets up \
  a development environment on a new machine. You might even want that!'
  spec.homepage      = 'https://github.com/tenebrousedge/enkaironment'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'fakefs', '0.18.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_dependency 'highline', '~> 2.0.0'
  spec.add_dependency 'i18n', '~> 1.1.1'
end
