#!/usr/bin/env ruby

# Load Rake
begin
  require 'rake'
rescue LoadError
  require 'rubygems'
  require 'rake'
end

# Added download task from buildr
require 'rake/downloadtask'
require 'rake/extracttask'

# RubyInstaller configuration data
require 'config/ruby_installer'

# DevKit configuration data
require 'config/devkit'

Dir.glob("#{RubyInstaller::ROOT}/recipes/**/*.rake").sort.each do |ext|
  puts "Loading #{File.basename(ext)}" if Rake.application.options.trace
  load ext
end
