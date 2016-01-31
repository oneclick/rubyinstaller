require 'rake'
require 'rake/clean'

desc "Build Ruby 2.3"
task :default => [:ruby23]

# Bring DevKit onto PATH before building
task :compiler => ['devkit:activate']

# Only unique cleanups
CLEAN.uniq!
CLOBBER.uniq!
