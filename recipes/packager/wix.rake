require 'rake'
require 'rake/clean'

def candle(list)
  puts "** compiling wxs files" if Rake.application.options.trace
  candle = File.expand_path(File.join(RubyInstaller::ROOT, 'sandbox/wix', 'candle.exe'))
  sh "\"#{candle}\" -nologo  #{list.join(' ')}"
end

def light(list, file)
  puts "** linking wixobj files" if Rake.application.options.trace
  wix_path = File.join(RubyInstaller::ROOT, 'sandbox/wix')
  ui_lib   = File.join(wix_path, 'wixui.wixlib')
  loc      = File.join(wix_path, 'WixUI_en-us.wxl')
  light   = File.join(wix_path, 'light.exe')
  sh "\"#{light}\" -nologo -out #{file} #{list.join(' ')} #{ui_lib} -loc #{loc}"  
end

def paraffin(file, options)
  paraffin = File.expand_path(File.join(RubyInstaller::ROOT, 'sandbox/wix/Debug', 'paraffin.exe'))
  sh "\"#{paraffin}\" #{options.to_a.join(' ')} #{file}" 
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

    task :candle do
      Dir.chdir('resources/installer') do
         wxs_files = FileList[ '*.wxs']
         candle wxs_files
      end
    end
    
    task :light => :candle do
      Dir.chdir('resources/installer') do
         wixobj_files = FileList[ '*.wixobj']
         light wixobj_files, package.package_file
      end
    end
    
    directory 'pkg'
    
    task :package => [:light, 'pkg'] do
      FileUtils.mv(File.join('resources/installer', package.package_file), 'pkg', :verbose => true)
    end

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
  
  namespace(:paraffin) do
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
      files = Rake::Task['packager:paraffin:download'].prerequisites

      files.each { |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      }
    end
    
    task :diff do
      Dir.chdir('resources/installer') do
         wxs_files = FileList.new('*.wxs'){|fl| fl.exclude('main.wxs') }
         wxs_files.each do |file|
           paraffin file, {'-update' => '' }
           file_name = File.basename(file, '.wxs')
           msys_sh "diff #{file_name}.PARAFFIN #{file} > #{file_name}.diff ;exit 0" 
         end
      end
    end
    
  end
  
end

task :download  => ['packager:wix:download', 'packager:paraffin:download']
task :extract   => ['packager:wix:extract', 'packager:paraffin:extract']

desc 'create an MSI package of the runtime'
task :package   => 'packager:wix:package'
task :diff_wxs => 'packager:paraffin:diff'

