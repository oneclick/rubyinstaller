require 'rake'
require 'rake/clean'

namespace(:dependencies) do
  namespace(:tcl) do
    package = RubyInstaller::Tcl
    compiler = DevKitInstaller::COMPILERS[ENV['DKVER']]

    directory package.target
    CLEAN.include(package.target)
    CLEAN.include(package.install_target)

    # Put files for the :download task
    dt = checkpoint(:tcl, :download)
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
    et = checkpoint(:tcl, :extract) do
      dt.prerequisites.each { |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      }
    end
    task :extract => [:extract_utils, :download, package.target, et]

    # Apply patches
    pt = checkpoint(:tcl, :prepare) do
      patches = Dir.glob("#{package.patches}/*.patch").sort
      patches.each do |patch|
        sh "git apply --ignore-whitespace --directory #{package.target} #{patch}"
      end
    end
    task :prepare => [:extract, pt]

    # Prepare sources for compilation
    ct = checkpoint(:tcl, :configure) do
      ENV['RC'] = "#{compiler.program_prefix}-windres" unless compiler.nil? || compiler.program_prefix.nil?

      install_target = File.join(RubyInstaller::ROOT, package.install_target)
      cd package.target do
        sh "sh tcl#{package.version}/win/configure #{package.configure_options.join(' ')} --prefix=#{install_target}"
      end
    end
    task :configure => [:prepare, :compiler, ct]

    mt = checkpoint(:tcl, :make) do
      cd package.target do
        sh "make"
      end
    end
    task :compile => [:configure, mt]

    it = checkpoint(:tcl, :install) do
      cd package.target do
        sh "make install"
      end
    end
    task :install => [:compile, it]

    task :activate => [:compile] do
      puts "Activating tcl version #{package.version}"
      activate(package.install_target)
    end
  end
end

task :tcl => [
  'dependencies:tcl:download',
  'dependencies:tcl:extract',
  'dependencies:tcl:prepare',
  'dependencies:tcl:configure',
  'dependencies:tcl:compile',
  'dependencies:tcl:install',
  'dependencies:tcl:activate'
]
