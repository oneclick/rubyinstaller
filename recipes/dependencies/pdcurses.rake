require 'rake'
require 'rake/clean'

namespace(:dependencies) do
  namespace(:pdcurses) do
    package = RubyInstaller::PdCurses
    directory package.target
    CLEAN.include(package.target)

    # Put files for the :download task
    dt = checkpoint(:pdcurses, :download)
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
    et = checkpoint(:pdcurses, :extract) do
      dt.prerequisites.each { |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      }
    end
    task :extract => [:extract_utils, :download, package.target, et]

    # pdcurses needs some relocation of files
    pt = checkpoint(:pdcurses, :prepare) do
      cd File.join(RubyInstaller::ROOT, package.target) do
        mkdir 'bin'
        mkdir 'include'
        mkdir 'lib'
        mv 'pdcurses.dll', 'bin'
        mv [ 'panel.h', 'curses.h' ], 'include'
        mv 'pdcurses.lib', 'lib/libcurses.a'
      end
    end
    task :prepare => [:extract, pt]

    task :activate => [:prepare] do
      puts "Activating pdcurses version #{package.version}"
      activate(package.target)
    end
  end
end

task :pdcurses => [
  'dependencies:pdcurses:download',
  'dependencies:pdcurses:extract',
  'dependencies:pdcurses:prepare',
  'dependencies:pdcurses:activate'
]
