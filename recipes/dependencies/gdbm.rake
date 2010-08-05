require 'rake'
require 'rake/clean'

namespace(:dependencies) do
  namespace(:gdbm) do
    package = RubyInstaller::Gdbm
    directory package.target
    CLEAN.include(package.target)

    # Put files for the :download task
    dt = checkpoint(:gdbm, :download)
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
    et = checkpoint(:gdbm, :extract) do
      dt.prerequisites.each { |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      }
    end
    task :extract => [:extract_utils, :download, package.target, et]

    # gdbm needs some adjustments.
    # move gdbm-dll.h from source to include
    # move ndbm.h from source to include
    # move dbm.h from source to include
    pt = checkpoint(:gdbm, :prepare) do
      cd File.join(RubyInstaller::ROOT, package.target) do
        ['gdbm-dll.h', 'ndbm.h', 'dbm.h'].each do |file|
          files = Dir.glob(File.join('src', 'gdbm', '*', 'gdbm-*-src', file))
          fail "#{files.size} #{file} files found." unless files.size == 1
          cp files[0], 'include'
        end
      end
    end
    task :prepare => [et, pt]

    task :activate => [:prepare] do
      puts "Activating gdbm version #{package.version}"
      activate(package.target)
    end
  end
end

task :gdbm => [
  'dependencies:gdbm:download',
  'dependencies:gdbm:extract',
  'dependencies:gdbm:prepare',
  'dependencies:gdbm:activate'
]

task :dependencies => [:gdbm] unless ENV['NODEPS']
