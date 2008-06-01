require 'rake'
require 'rake/clean'

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

      files.each { |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      }
    end

    # TODO: use paraffin to generate the WiX fragments for ruby and rubygems
    # cmd: paraffin -dir ..\..\sandbox\ruby_mingw\bin -custom RUBY_BIN -guids -multiple -alias ..\..\sandbox\ruby_mingw\bin ruby_bin.wxs
    # cmd: paraffin -dir ..\..\sandbox\ruby_mingw\lib -custom RUBY_LIB -guids -multiple -alias ..\..\sandbox\ruby_mingw\lib ruby_lib.wxs -direXclude gems
    # cmd: paraffin -dir ..\..\sandbox\ruby_mingw\share -custom RUBY_SHARE -guids -multiple -alias ..\..\sandbox\ruby_mingw\share ruby_share.wxs

    # cmd: paraffin -dir ..\..\sandbox\rubygems_mingw\bin -custom RUBYGEMS_BIN -guids -multiple -alias ..\..\sandbox\rubygems_mingw\bin rubygems_bin.wxs
    # cmd: paraffin -dir ..\..\sandbox\rubygems_mingw\lib -custom RUBYGEMS_LIB -guids -multiple -alias ..\..\sandbox\rubygems_mingw\lib rubygems_lib.wxs

    # TODO: only needed is -update to update each fragment!
    # cmd: paraffin -update file.wxs
  end
end

task :download  => ['packager:wix:download']
task :extract   => ['packager:wix:extract']
