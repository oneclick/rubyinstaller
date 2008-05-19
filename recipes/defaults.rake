require 'rake'
require 'rake/clean'

desc "Download all components."
task :download

desc "Extract all downloaded components."
task :extract

desc "Prepare the freshly extracted components."
task :prepare

desc "Run the configure process for the interpreter."
task :configure

desc "Compile the interpreter."
task :compile

desc "Install the interpreter in the sandbox."
task :install

desc "Run tests for the interpreter in the sandbox."
task :check

desc "Do everything!"
task :default => [:download, :extract, :prepare, :configure, :compile, :install]

# TODO: specs
