require 'rake'
require 'rake/clean'

desc "Build Ruby 1.8"
task :default => [:ruby18]

# Bring DevKit onto PATH before building
task :compiler => ['devkit:activate']

# Only unique cleanups
CLEAN.uniq!
CLOBBER.uniq!
