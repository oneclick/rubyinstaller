require 'rake'
require 'rake/clean'

def candle(list)
  puts "** compiling wxs files" if Rake.application.options.trace
  candle = File.expand_path(File.join(RubyInstaller::ROOT, 'sandbox/wix', 'candle.exe'))
  sh "\"#{candle}\" -nologo  #{list.join(' ')}"
end

def light(list, file)
  puts "** linking wixobj files" if Rake.application.options.trace
  light = File.expand_path(File.join(RubyInstaller::ROOT, 'sandbox/wix', 'light.exe'))
  sh "\"#{light}\" -nologo -out #{file} #{list.join(' ')}"  
end

namespace(:packager) do
  namespace(:wix) do
    package = RubyInstaller::Wix
    directory package.target
    CLEAN.include(package.target)
    CLEAN.include(package.package_target)
    
    # Put files for the :download task
    package.files.each do |f|
      file_source = "#{package.url}/#{f}"
      file_target = "downloads/#{f}"
      download file_target => file_source
      
      # depend on downloads directory
      file file_target => "downloads"
      
      # download task need these files as pre-requisites
      task :download => file_target
    end

    # Prepare the :sandbox, it requires the :download task
    task :extract => [:extract_utils, :download, package.target] do
      # grab the files from the download task
      files = Rake::Task['packager:wix:download'].prerequisites

      files.each do |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      end
    end

    directory package.package_target
    
    task :prepare => package.package_target do
      FileUtils.cp_r(Dir.glob('resources/installer/*'), package.package_target, :verbose => true)
    end
    
    task :candle => :prepare do
      Dir.chdir(package.package_target) do
         wxs_files = FileList[ '*.wxs']
         candle wxs_files
      end
    end
    
    task :light => :candle do
      Dir.chdir(package.package_target) do
         wixobj_files = FileList[ '*.wixobj']
         light wixobj_files, package.package_file
      end
    end
    
    directory 'package'
    
    task :package => [:light, 'package'] do
      FileUtils.cp(File.join(package.package_target, package.package_file), 'package', :verbose => true)
    end

    # TODO: Test for .net 3.5 using Win32/Registry (Parafin may do this)
    
    # HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5  == 1
    # HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\User Agent\Post Platform\
    # == '.NET CLR 3.5.build number'  

    # URL:  http://msdn.microsoft.com/en-us/library/cc160716.aspx

    # TODO: use paraffin to generate the WiX fragments for ruby and rubygems
    # cmd: paraffin -dir ..\..\sandbox\ruby_mingw\bin -custom RUBY_BIN -guids -multiple -alias ..\..\sandbox\ruby_mingw\bin ruby_bin.wxs
    # cmd: paraffin -dir ..\..\sandbox\ruby_mingw\lib -custom RUBY_LIB -guids -multiple -alias ..\..\sandbox\ruby_mingw\lib ruby_lib.wxs -direXclude gems
    # cmd: paraffin -dir ..\..\sandbox\ruby_mingw\share -custom RUBY_SHARE -guids -multiple -alias ..\..\sandbox\ruby_mingw\share ruby_share.wxs

    # cmd: paraffin -dir ..\..\sandbox\rubygems_mingw\bin -custom RUBYGEMS_BIN -guids -multiple -alias ..\..\sandbox\rubygems_mingw\bin rubygems_bin.wxs
    # cmd: paraffin -dir ..\..\sandbox\rubygems_mingw\lib -custom RUBYGEMS_LIB -guids -multiple -alias ..\..\sandbox\rubygems_mingw\lib rubygems_lib.wxs

    # TODO: only needed is -update to update each fragment!
    # cmd: paraffin -update file.wxs
  end
  
  namespace(:parrafin) do
    package = RubyInstaller::Paraffin
    directory package.target
    CLEAN.include(package.target)
    
    # Put files for the :download task
    package.files.each do |f|
      file_source = "#{package.url}"
      file_target = "downloads/#{f}"
      download file_target => file_source
      
      # depend on downloads directory
      file file_target => "downloads"
      
      # download task need these files as pre-requisites
      task :download => file_target
    end

    # Prepare the :sandbox, it requires the :download task
    task :extract => [:extract_utils, :download, package.target] do
      # grab the files from the download task
      files = Rake::Task['packager:parrafin:download'].prerequisites

      files.each { |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      }
    end
  end
  
end

task :download  => ['packager:wix:download', 'packager:parrafin:download']
task :extract   => ['packager:wix:extract', 'packager:parrafin:extract']
task :package   => 'packager:wix:package'
