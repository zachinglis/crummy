$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'crummy/version'

Gem::Specification.new do |s|
  s.name = 'crummy'
  s.version = Crummy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.licenses    = ['MIT']

  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.authors = ['Zach Inglis', 'Andrew Nesbitt']
  s.summary = 'Tasty breadcrumbs!'
  s.description = 'Crummy is a simple and tasty way to add breadcrumbs to your Rails applications.'
  s.email = 'zach+crummy@londonmade.co.uk'
  s.extra_rdoc_files = ['README.md']

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.homepage = 'http://github.com/zachinglis/crummy'
  s.require_paths = ['lib']
  s.rubygems_version = '1.9.0'

  s.add_development_dependency 'actionpack'
  s.add_development_dependency 'activesupport'
  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'bundler', '~> 1.0'
  s.add_development_dependency('rails-dom-testing')
  s.add_development_dependency 'rake'
  s.add_development_dependency 'test-unit'
end
