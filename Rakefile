require 'rubygems'
require 'rake'

desc 'Default: run unit tests.'
task :default => :test

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "crummy"
    gem.summary = %Q{Tasty breadcrumbs!}
    gem.description = %Q{Crummy is a simple and tasty way to add breadcrumbs to your Rails applications.}
    gem.email = "iempire@iempire.ru"
    gem.homepage = "http://github.com/shatrov/crummy"
    gem.authors = ["Kir Shatrov"]
    gem.files = FileList['lib/**/*.rb','tasks/*.rake','init.rb','MIT-LICENSE','Rakefile','README.textile','VERSION', '.gitignore']
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
desc 'Test the crummy plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

begin
  gem 'hanna'
  require 'hanna/rdoctask'
rescue LoadError
  require 'rake/rdoctask'
end
desc 'Generate documentation for the crummy plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Crummy: Tasty Breadcrumbs'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.textile')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
