require 'rake'
require 'rake/clean'

namespace(:dependencies) do
  namespace(:iconv) do
    # zlib needs mingw and downloads
    package = RubyInstaller::Iconv
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
      files = Rake::Task['dependencies:iconv:download'].prerequisites

      files.each { |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      }
    end
    
    task :prepare => [package.target] do
      # win_iconv needs some adjustments.
      # remove *.txt
      # remove src folder
      # leave zlib1.dll inside bin ;-)
      Dir.chdir(File.join(RubyInstaller::ROOT, package.target)) do
        FileUtils.rm_rf("src")
        Dir.glob("*.txt").each do |f|
          FileUtils.rm_f(f)
        end
      end
    end
  end
end

task :download  => ['dependencies:iconv:download']
task :extract   => ['dependencies:iconv:extract']
task :prepare   => ['dependencies:iconv:prepare']
