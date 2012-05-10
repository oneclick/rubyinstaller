#!/usr/bin/env ruby

# Ensure '.' is in the LOAD_PATH in Ruby 1.9.2
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

# Load Rake
begin
  require 'rake'
rescue LoadError
  require 'rubygems'
  require 'rake'
end

# Add extensions to core Ruby classes
require 'rake/core_extensions'

# RubyInstaller configuration data
require 'config/ruby_installer'

# DevKit configuration data
require 'config/devkit'

# Docs configuration data
require 'config/docs'

# Added download task from buildr
require 'rake/downloadtask'
require 'rake/extracttask'
require 'rake/checkpoint'
require 'rake/env'

# scan all override definitions and load them
Dir.glob('override/*.rb').sort.each do |f|
  begin
    puts "Loading override #{File.basename(f)}" if Rake.application.options.trace
    require f
  rescue StandardError => e
    warn "WARN: Problem loading #{f}: #{e.message}"
  end
end

Dir.glob("#{RubyInstaller::ROOT}/recipes/**/*.rake").sort.each do |ext|
  puts "Loading #{File.basename(ext)}" if Rake.application.options.trace
  load ext
end
