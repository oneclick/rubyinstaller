require 'rake'
require 'rake/clean'

namespace(:dependencies) do
  namespace(:pthreads) do
    # zlib needs mingw and downloads
    package = RubyInstaller::PThreads
    directory package.target
    CLEAN.include(package.target)

    # Put files for the :download task
    dt = checkpoint(:pthreads, :download)
    package.files.each do |f|
      file_source = "#{package.url}/#{f}"
      file_target = "downloads/#{f}"
      download file_target => file_source

      # depend on downloads directory
      file file_target => "downloads"

      # download task need these files as pre-requisites
      dt.enhance [file_target]
    end
    task :download => dt

    # Prepare the :sandbox, it requires the :download task
    et = checkpoint(:pthreads, :extract) do
      dt.prerequisites.each { |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      }
    end
    task :extract => [:extract_utils, :download, package.target, et]

    task :activate => [:extract] do
      puts "Activating pthreads-win32 version #{package.version}"
      activate(package.target)
    end
  end
end

task :pthreads => [
  'dependencies:pthreads:download',
  'dependencies:pthreads:extract',
  'dependencies:pthreads:activate'
]
