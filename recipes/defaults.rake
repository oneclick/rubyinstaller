require 'rake'
require 'rake/clean'

# Placeholder for NODEPS usage.
task :dependencies

desc "Build Ruby 1.8"
task :default => [:ruby18]

desc "Run tests for the interpreter in the sandbox."
task :check

desc "Test drive the sandbox (using IRB)."
task :irb

# Use DevKit in the PATH
task :compiler => ['devkit:env']
