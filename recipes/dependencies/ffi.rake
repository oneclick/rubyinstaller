require 'rake'
require 'rake/clean'

namespace(:dependencies) do
  namespace(:ffi) do
    package = RubyInstaller::LibFFI
    directory package.target
    CLEAN.include(package.target)
    CLEAN.include(package.install_target)

    # Put files for the :download task
    dt = checkpoint(:ffi, :download)
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
    et = checkpoint(:ffi, :extract) do
      dt.prerequisites.each { |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      }
    end
    task :extract => [:extract_utils, :download, package.target, et]

    # Apply patches
    pt = checkpoint(:ffi, :prepare) do
      patches = Dir.glob("#{package.patches}/*.patch").sort
      patches.each do |patch|
        sh "git apply --directory #{package.target} #{patch}"
      end
    end
    task :prepare => [:extract, pt]

    # Prepare sources for compilation
    ct = checkpoint(:ffi, :configure) do
      install_target = File.join(RubyInstaller::ROOT, package.install_target)
      cd package.target do
        sh "sh -c \"./configure #{package.configure_options.join(' ')} --prefix=#{install_target}\""
      end
    end
    task :configure => [:prepare, :compiler, ct]

    mt = checkpoint(:ffi, :make) do
      cd package.target do
        sh "make"
      end
    end
    task :compile => [:configure, mt]

    it = checkpoint(:ffi, :install) do
      cd package.target do
        sh "make install"
      end
    end
    task :install => [:compile, it]

    task :activate => [:compile] do
      puts "Activating libffi version #{package.version}"
      activate(package.install_target)
    end
  end
end

task :ffi => [
  'dependencies:ffi:download',
  'dependencies:ffi:extract',
  'dependencies:ffi:prepare',
  'dependencies:ffi:configure',
  'dependencies:ffi:compile',
  'dependencies:ffi:install',
  'dependencies:ffi:activate'
]
