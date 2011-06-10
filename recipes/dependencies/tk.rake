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

    task :activate => [:install] do
      puts "Activating tk version #{package.version}"
      activate(package.install_target)
    end

    task :install19 => [:activate, RubyInstaller::Ruby19.install_target, *package.dependencies] do
      tcltk_install RubyInstaller::Ruby19
      tk_patch package, RubyInstaller::Ruby19
    end

  private

    def tcltk_install(interpreter)
      # DLLs are already copied by ruby own install task, so copy the remaining bits
      target = File.join(interpreter.install_target, "lib", "tcltk")
      mkdir_p target

      [RubyInstaller::Tcl.install_target, RubyInstaller::Tk.install_target].each do |pkg_dir|
        pattern = "#{pkg_dir}/lib/*"
        Dir.glob(pattern).each do |f|
          next if f =~ /\.(a|sh)$/

          if File.directory?(f)
            cp_r f, target, :remove_destination => true
          else
            cp_f f, target
          end
        end
      end
    end

    def tk_patch(package, interpreter)
      target = Dir.glob("#{interpreter.install_target}/lib/ruby/**/tk.rb").first
      parent = File.dirname(target)

      # use diffs instead of patch so we can apply post_install
      diffs = Dir.glob("#{package.patches}/*.diff").sort
      diffs.each do |diff|
        sh "git apply --directory #{parent} #{diff}"
      end
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
