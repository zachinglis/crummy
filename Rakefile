#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'appraisal'

desc 'Default: run unit tests.'
task default: :test

require 'rake/testtask'
desc 'Test the crummy plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

require 'rdoc/task'

desc 'Generate documentation for the crummy plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Crummy: Tasty Breadcrumbs'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.textile')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
