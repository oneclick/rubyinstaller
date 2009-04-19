require 'rake'
require 'rake/clean'

def candle(*list)
  puts "** compiling wxs files" if Rake.application.options.trace
  candle = File.expand_path(File.join(RubyInstaller::ROOT, 'sandbox', 'wix', 'candle.exe'))
  sh "\"#{candle}\" -nologo  #{list.join(' ')}"
end

def light(list, file)
  puts "** linking wixobj files" if Rake.application.options.trace
  wix_path = File.join(RubyInstaller::ROOT, 'sandbox', 'wix')
  ui_lib   = File.join(wix_path, 'wixui.wixlib')
  loc      = File.join(wix_path, 'WixUI_en-us.wxl')
  light    = File.join(wix_path, 'light.exe')
  sh "\"#{light}\" -nologo -out #{file} #{list.join(' ')} #{ui_lib} -loc #{loc}"  
end

def paraffin(file, *args)
  paraffin = File.expand_path(File.join(RubyInstaller::ROOT, 'sandbox/wix/Debug', 'paraffin.exe'))
  sh "\"#{paraffin}\" #{args.join(' ')} #{file}" 
end

def diff(file1, file2)
  msys_system "diff -u -I\\<CreatedOn\\> #{file1} #{file2} > #{file1.ext('diff')}"
end

namespace(:packager) do
  namespace(:wix) do
    package = RubyInstaller::Wix
    directory package.target
    CLEAN.include(package.target)
    
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
    
    task :diff => [:paraffin] do
      cd 'resources/installer' do
         wxs_files = FileList.new('*.wxs'){|fl| fl.exclude('main.wxs', '*_env.wxs') }
         
         diffs = wxs_files.reject do |file|
           paraffin file, '-update'
           diff file, file.ext('PARAFFIN')
         end
         
         puts (diffs.empty? ? "All files are correct." : "These files need to be edited:")
         puts diffs  
      end
    end
    
  end
  
end

task :wix => [
  'packager:wix:download',
  'packager:wix:extract',
]

task :paraffin => [
  'packager:paraffin:download',
  'packager:paraffin:extract'
]

desc 'create an MSI package of the runtime'
task :diff_wxs => 'packager:paraffin:diff'
