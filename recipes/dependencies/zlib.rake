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
      cd File.join(RubyInstaller::ROOT, package.target) do
        rm_rf "test"
        Dir.glob("*.txt").each do |path|
          rm_f path
        end
        mv "zlib1.dll", "bin"
      end
    end
  end
end

task :zlib => [
  'dependencies:zlib:download',
  'dependencies:zlib:extract',
  'dependencies:zlib:prepare'
]

task :dependencies => [:zlib]
