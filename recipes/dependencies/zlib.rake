require 'rake'
require 'rake/clean'

namespace(:dependencies) do
  namespace(:zlib) do
    # zlib needs mingw and downloads
    package = RubyInstaller::Zlib
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
      files = Rake::Task['dependencies:zlib:download'].prerequisites

      files.each { |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      }
    end
    
    task :prepare => [package.target] do
      # zlib needs some relocation of files
      # remove test/*.exe
      # remove *.txt
      # move zlib1.dll to bin
      Dir.chdir(File.join(RubyInstaller::ROOT, package.target)) do
        FileUtils.rm_rf("test")
        Dir.glob("*.txt").each do |f|
          FileUtils.rm_f(f)
        end
        FileUtils.mv("zlib1.dll", "bin")
      end
    end
  end
end

task :download  => ['dependencies:zlib:download']
task :extract   => ['dependencies:zlib:extract']
task :prepare   => ['dependencies:zlib:prepare']
