require 'rake'
require 'rake/clean'

namespace(:dependencies) do
  namespace(:gdbm) do
    package = RubyInstaller::Gdbm
    compiler = DevKitInstaller::COMPILERS[ENV['DKVER']]
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

    # Apply patches
    pt = checkpoint(:gdbm, :prepare) do
      patches = Dir.glob("#{package.patches}/*.patch").sort
      patches.each do |patch|
        sh "git apply --directory #{package.target} #{patch}"
      end
    end
    task :prepare => [:extract, pt]

    # Prepare sources for compilation
    ct = checkpoint(:gdbm, :configure) do
      install_target = File.join(RubyInstaller::ROOT, package.install_target)

      cd package.target do
        sh "sh ./configure #{package.configure_options.join(' ')} --prefix=#{install_target}"
      end
    end
    task :configure => [:prepare, :compiler, ct]

    mt = checkpoint(:gdbm, :make) do
      cd package.target do
        sh "make"
      end
    end
    task :compile => [:configure, mt]

    it = checkpoint(:gdbm, :install) do
      cd package.target do
        sh "make install"
        sh "make install-compat"
      end
    end
    task :install => [:compile, it]

    task :activate => [:install] do
      puts "Activating gdbm version #{package.version}"
      activate(package.install_target)
    end
  end
end

task :gdbm => [
  'dependencies:gdbm:download',
  'dependencies:gdbm:extract',
  'dependencies:gdbm:prepare',
  'dependencies:gdbm:configure',
  'dependencies:gdbm:compile',
  'dependencies:gdbm:install',
  'dependencies:gdbm:activate'
]
