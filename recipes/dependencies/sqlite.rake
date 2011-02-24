require 'rake'
require 'rake/clean'

namespace(:dependencies) do
  namespace(:sqlite) do
    package = RubyInstaller::Sqlite
    directory package.target
    CLEAN.include(package.target)

    # Put files for the :download task
    dt = checkpoint(:sqlite, :download)
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
    et = checkpoint(:sqlite, :extract) do
      dt.prerequisites.each { |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      }
      package.files.each {|f|
        extract(File.join(RubyInstaller::ROOT, "downloads", f), package.target)
      }
    end
    task :extract => [:extract_utils, :download, package.target, et]

    mingw_root = File.join RubyInstaller::ROOT, "sandbox/mingw"

    task :prepare => [package.target] do
      cp(
        File.join(package.target, 'sqlite3.dll'),
        File.join(mingw_root, 'bin')
      )
      cp(
        File.join(package.target, 'sqlite3.h'),
        File.join(mingw_root, 'include')
      )
    end
    
    task :link_dll => [:prepare] do
      p "dlltool --dllname #{package.target}/sqlite3.dll --def #{package.target}/sqlite3.def --output-lib #{mingw_root}/lib/sqlite3.lib"
      sh "bash --login -i -c \"cd \"#{File.expand_path package.target}\" && dlltool --dllname sqlite3.dll --def sqlite3.def --output-lib #{mingw_root}/lib/sqlite3.lib"
    end


    task :activate do
      puts "Activating sqlite version #{package.version}"
      activate(package.target)
    end
  end
end

task :sqlite => [
  'dependencies:sqlite:download',
  'dependencies:sqlite:extract',
  'dependencies:sqlite:prepare',
  'dependencies:sqlite:link_dll',
  'dependencies:sqlite:activate'
]
