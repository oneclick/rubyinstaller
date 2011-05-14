require 'rake'
require 'rake/clean'

namespace(:dependencies) do
  namespace(:zlib) do
    # zlib needs mingw and downloads
    package = RubyInstaller::Zlib
    directory package.target
    CLEAN.include(package.target)

    # Put files for the :download task
    dt = checkpoint(:zlib, :download)
    if DevKitInstaller.compiler.bit == 64
      url = package.url_64
      files = package.files_64
    else
      url = package.url
      files = package.files
    end
    files.each do |f|
      file_source = "#{url}/#{f}"
      file_target = "downloads/#{f}"
      download file_target => file_source

      # depend on downloads directory
      file file_target => "downloads"

      # download task need these files as pre-requisites
      dt.enhance [file_target]
    end
    task :download => dt

    # Prepare the :sandbox, it requires the :download task
    et = checkpoint(:zlib, :extract) do
      dt.prerequisites.each { |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      }
    end
    task :extract => [:extract_utils, :download, package.target, et]

    # zlib needs some relocation of files
    # remove test/*.exe
    # remove *.txt
    # move zlib1.dll to bin
    pt = checkpoint(:zlib, :prepare) do
      cd File.join(RubyInstaller::ROOT, package.target) do
        rm_rf "test"
        Dir.glob("*.txt").each do |path|
          rm_f path
        end
        mkdir 'bin'
        mv "zlib1.dll", "bin"
      end
    end
    task :prepare => [:extract, pt]

    task :activate => [:prepare] do
      puts "Activating zlib version #{package.version}"
      activate(package.target)
    end
  end
end

task :zlib => [
  'dependencies:zlib:download',
  'dependencies:zlib:extract',
  'dependencies:zlib:prepare',
  'dependencies:zlib:activate'
]
