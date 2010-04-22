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
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = "barricade"
    gem.summary     = "Better ActiveRecord locking"
    gem.description = "Makes ActiveRecord locking more secure and robust"
    gem.email       = "pete@envato.com"
    gem.homepage    = "http://github.com/envato/barricade"
    gem.authors     = ["Pete Yandell"]

    gem.add_development_dependency "rspec", ">= 1.2.9"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

