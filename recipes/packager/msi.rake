require 'rake'
require 'rake/clean'

def ruby_version(file)
  return nil unless File.exist?(file)
  version_file = File.read(file)
  ver = /RUBY_VERSION_CODE (.+)$/.match(version_file)[1]
  pl = /RUBY_PATCHLEVEL (.+)$/.match(version_file)[1]
  "#{ver}-p#{pl}"
end

packages = [RubyInstaller::Runtime, RubyInstaller::DevKit]

packages.each do |pkg|
  
  version_file = File.join(RubyInstaller::ROOT, pkg.version_source, 'version.h')
  pkg.version = ruby_version(version_file) || pkg.version
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
   
    task :compile => :env do |t|
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