require 'rake'

desc 'Default: run specs.'
task :default => :spec

require 'spec/rake/spectask'
desc 'Run the specs.'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

require 'rake/rdoctask'
desc 'Generate documentation'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Barricade'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name        = "barricade"
  gem.summary     = "Better ActiveRecord locking"
  gem.description = "Makes ActiveRecord locking more secure and robust"
  gem.email       = "pete@envato.com"
  gem.homepage    = "http://github.com/envato/barricade"
  gem.authors     = ["Pete Yandell"]
  
  gem.files = FileList[
    'init.rb',
    'lib/**/*.rb',
    'LICENCE',
    'README.md',
    'spec/**/*.rb'
  ]
end

Jeweler::GemcutterTasks.new

