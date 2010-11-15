require 'rubygems'
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the preference_fu plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the preference_fu plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'PreferenceFu'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
                 
require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "preference_fu"
  gem.summary = %Q{Rails 3 compatible plugin gem for boolean preferences for an ActiveRecord model}
  gem.description = %Q{This plugin, greatly inspired by Jim Morris' blog post (http://blog.wolfman.com/articles/2007/08/07/bit-vector-preferences), aims to make it easy and flexible to store boolean preferences for an ActiveRecord model.This can be also used as a very quick way to setup an ACL.  Because the values are stored within a bit vector, a virtually unlimited number of preferences can be created without additional  migrations.}
  gem.email = ""
  gem.homepage = "http://github.com/g5search/preference_fu"
  gem.authors = ["Brennan Dunn"]                           
  gem.has_rdoc=true 
end                 
Jeweler::GemcutterTasks.new
