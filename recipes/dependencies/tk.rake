require 'rake'
require 'rake/clean'

namespace(:dependencies) do
  namespace(:tk) do
    package = RubyInstaller::Tk
    tcl = RubyInstaller::Tcl

    directory package.target
    CLEAN.include(package.target)
    CLEAN.include(package.install_target)

    # Put files for the :download task
    dt = checkpoint(:tk, :download)
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
    et = checkpoint(:tk, :extract) do
      dt.prerequisites.each { |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      }
    end
    task :extract => [:extract_utils, :download, package.target, et]

    task :dependencies => package.dependencies

    # Apply patches
    pt = checkpoint(:tk, :prepare) do
      patches = Dir.glob("#{package.patches}/*.patch").sort
      patches.each do |patch|
        sh "git apply --directory #{package.target} #{patch}"
      end
    end
    task :prepare => [:extract, pt]

    # Prepare sources for compilation
    ct = checkpoint(:tk, :configure) do
      install_target = File.join(RubyInstaller::ROOT, package.install_target)
      tcl_target = File.join(RubyInstaller::ROOT, tcl.target)

      package.configure_options << "--with-tcl=#{tcl_target}"

      cd package.target do
        sh "sh tk#{package.version}/win/configure #{package.configure_options.join(' ')} --prefix=#{install_target}"
      end
    end
    task :configure => [:prepare, :compiler, :dependencies, ct]

    mt = checkpoint(:tk, :make) do
      cd package.target do
        sh "make"
      end
    end
    task :compile => [:configure, mt]

    it = checkpoint(:tk, :install) do
      cd package.target do
        sh "make install"
      end
    end
    task :install => [:compile, it]

    task :activate => [:compile] do
      puts "Activating tk version #{package.version}"
      activate(package.install_target)
    end
  end
end

task :tk => [
  'dependencies:tk:download',
  'dependencies:tk:extract',
  'dependencies:tk:prepare',
  'dependencies:tk:configure',
  'dependencies:tk:compile',
  'dependencies:tk:install',
  'dependencies:tk:activate'
]
