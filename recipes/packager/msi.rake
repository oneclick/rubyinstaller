require 'rake'
require 'rake/clean'
require 'erb'

def ruby_version(file)
  return nil unless File.exist?(file)
  h = {}
  version_file = File.read(file)
  h[:version] = /RUBY_VERSION "(.+)"$/.match(version_file)[1]
  h[:patchlevel] = /RUBY_PATCHLEVEL (.+)$/.match(version_file)[1]
  h
end

def rubygems_version(target)
  cd target do
    @ret = `ruby -Ilib bin/gem environment packageversion`.chomp
  end
  @ret
end

packages = [RubyInstaller::Runtime18, RubyInstaller::Runtime19]

packages.each do |pkg|

  version_file = File.join(RubyInstaller::ROOT, pkg.ruby_version_source, 'version.h')
  pkg.info    = ruby_version(version_file)
  pkg.version = pkg.info.nil? ? pkg.version : "#{pkg.info[:version]}-p#{pkg.info[:patchlevel]}"
  pkg.file = "#{pkg.package_name}-#{pkg.version}.msi"
  pkg.target = "pkg\\#{pkg.file}"

  namespace(pkg.namespace) do

    task :env do
      ENV['RUNTIME_NAME'] = pkg.namespace.capitalize
      ENV['PACKAGE_CONFIG'] = "config.#{pkg.namespace}.wxi"
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
      pkg.wix_config['ProductVersion'] = "#{pkg.info[:version]}.#{pkg.info[:patchlevel]}"
      pkg.wix_config['RubyVersion'] = "#{pkg.info[:version] } patchlevel #{pkg.info[:patchlevel] }"
      gems = File.join(RubyInstaller::ROOT, pkg.rubygems_version_source)
      pkg.wix_config['RubyGemsVersion'] = rubygems_version(gems)
      config_file = File.join(RubyInstaller::ROOT, pkg.source, pkg.config_file)
      template = ERB.new(File.read(config_file))
      output = File.join(File.dirname(config_file), ENV['PACKAGE_CONFIG'])
      File.open(output, 'w+'){|f| f.write template.result }
    end
   
    task :compile => :configure do
      cd pkg.source do
        candle *pkg.wix_files
      end
    end
    
    directory 'pkg'

    wix_files = pkg.wix_files.map { |f| File.join(pkg.source, f) }

    # packaging requires wix
    file pkg.target => [:wix, 'pkg', *wix_files ] do
      Rake::Task["#{pkg.namespace}:compile"].invoke
      cd pkg.source do
        wixobj = pkg.wix_files.map { |f| f.ext('wixobj') }
        light wixobj, File.join(RubyInstaller::ROOT, pkg.target).gsub('/','\\')
      end
    end
    
    desc "compile #{pkg.file}"
    task :package => pkg.target
    
    task :clobber do
     rm_f pkg.target
    end
    
  end

  task :package => [:wix]

  desc "compile #{pkg.namespace} msi"
  task :package => ["#{pkg.namespace}:package"]
  desc "remove #{pkg.namespace} msi"
  task :clobber_package   => ["#{pkg.namespace}:clobber"]
  
end

desc "remove and rebuild msi"
task :repackage => [:clobber_package, :package]
