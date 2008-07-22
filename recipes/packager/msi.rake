require 'rake'
require 'rake/clean'
require 'erb'

def ruby_version(file)
  return nil unless File.exist?(file)
  h = {}
  version_file = File.read(file)
  h[:version] = /RUBY_VERSION "(.+)"$/.match(version_file)[1]
  h[:version_code] = /RUBY_VERSION_CODE (.+)$/.match(version_file)[1]
  h[:patchlevel] = /RUBY_PATCHLEVEL (.+)$/.match(version_file)[1]
  h
end

def rubygems_version(target)
  Dir.chdir(target) do
    @ret = `ruby -Ilib bin/gem environment packageversion`.chomp
  end
  @ret
end

packages = [RubyInstaller::Runtime, RubyInstaller::DevKit]

packages.each do |pkg|
  
  version_file = File.join(RubyInstaller::ROOT, pkg.ruby_version_source, 'version.h')
  pkg.info    = ruby_version(version_file)
  pkg.version = "#{pkg.info[:version_code]}-p#{pkg.info[:patchlevel]}" || pkg.version
  pkg.file = "#{pkg.package_name}-#{pkg.version}.msi"  
  pkg.target = "pkg\\#{pkg.file}"
  
  namespace(pkg.namespace) do

    task :env do
      ENV['PACKAGE'] = pkg.namespace.upcase
    end
    
    desc "install the product #{pkg.target}"
    task :install => pkg.target do
      sh "msiexec /i #{pkg.target}"
    end
    
    desc "uninstall the #{pkg.namespace} "
    task :uninstall => pkg.target  do
      sh "msiexec /x #{pkg.target}"
    end
    
    desc "run #{pkg.namespace} installer without installing the product"
    task :test_run => pkg.target  do
      sh "msiexec /i #{pkg.target} EXECUTEMODE=None"
    end
    
    task :configure => :env do
      pkg.wix_config['RubyVersion'] = "#{pkg.info[:version] } patchlevel #{pkg.info[:patchlevel] }"
      gems = File.join(RubyInstaller::ROOT, pkg.rubygems_version_source)
      pkg.wix_config['RubyGemsVersion'] = rubygems_version(gems)
      config_file = File.join(RubyInstaller::ROOT, pkg.source, pkg.config_file)
      template = ERB.new(File.read(config_file))
      output = File.join(File.dirname(config_file), File.basename(config_file, '.erb'))
      File.open(output, 'w+'){|f| f.write template.result }
    end
   
    task :compile => :configure do
      Dir.chdir(pkg.source) do
        candle *FileList[ '*.wxs' ]
      end
    end
    
    directory 'pkg'
    
    file pkg.target => ['pkg', *FileList[ File.join(pkg.source, '*.wxs') ] ] do
      Rake::Task["#{pkg.namespace}:compile"].invoke
      Dir.chdir(pkg.source) do
        wixobj = FileList[ '*.wixobj']
        light wixobj, File.join(RubyInstaller::ROOT, pkg.target).gsub('/','\\')
      end
    end
    
    desc "compile #{pkg.file}"
    task :package => pkg.target
    
  end
  
  desc "compile #{pkg.namespace} msi"
  task :package => "#{pkg.namespace}:package"
  
end