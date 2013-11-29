require 'rake'
require 'rake/clean'
require 'pathname'

namespace(:interpreter) do
  namespace(:ruby21) do
    package = RubyInstaller::Ruby21
    directory package.build_target
    directory package.install_target
    CLEAN.include(package.target)
    CLEAN.include(package.build_target)
    CLEAN.include(package.install_target)

    # Put files for the :download task
    package.files.each do |f|
      file_source = "#{package.url}/#{f}"
      file_target = "downloads/#{f}"
      download file_target => file_source

      # depend on downloads directory
      file file_target => "downloads"

      # download task need these files as pre-requisites
      task :download => file_target
    end

    task :checkout => "downloads" do
      cd RubyInstaller::ROOT do
        # If is there already a checkout, update instead of checkout"
        if File.exist?(File.join(RubyInstaller::ROOT, package.checkout_target, '.svn'))
          sh "svn update #{package.checkout_target}"
        else
          sh "svn co #{package.checkout} #{package.checkout_target}"
        end
      end
    end

    task :clean do
      rm_rf package.build_target
      rm_rf package.install_target
    end

    task :sources do
      case
      when ENV['LOCAL']
      when ENV['CHECKOUT']
        Rake::Task['interpreter:ruby21:checkout'].invoke
      else
        Rake::Task['interpreter:ruby21:download'].invoke
      end
    end

    task :extract => [:extract_utils] do
      case
      when ENV['LOCAL']
      when ENV['CHECKOUT']
        package.target = File.expand_path(package.checkout_target)
      else
        # grab the files from the download task
        files = Rake::Task['interpreter:ruby21:download'].prerequisites

        # ensure target directory exist
        mkdir_p package.target

        files.each { |f|
          extract(File.join(RubyInstaller::ROOT, f), package.target)
        }
      end
    end

    task :prepare => [package.build_target] do
      cd RubyInstaller::ROOT do
        cp_r(Dir.glob('resources/icons/*.ico'), package.build_target, :verbose => true)
      end

      patches = Dir.glob("#{package.patches}/*.patch").sort
      patches.each do |patch|
        sh "git apply --directory #{package.target} #{patch}"
      end

      # FIXME: Readline is not working, remove it for now (only from packages)
      unless ENV['LOCAL'] || ENV['CHECKOUT']
        Dir.chdir package.target do
          FileUtils.rm_f 'test/readline/test_readline.rb'
          FileUtils.rm_f 'test/readline/test_readline_history.rb'
        end
      end
    end

    task :dependencies => package.dependencies

    task :configure => [package.build_target, :compiler, :dependencies] do
      source_path = Pathname.new(File.expand_path(package.target))
      build_path = Pathname.new(File.expand_path(package.build_target))

      relative_path = source_path.relative_path_from(build_path)

      # working with a checkout, generate configure
      unless uptodate?(File.join(package.target, 'configure'), [File.join(package.target, 'configure.in')])
        cd package.target do
          sh "sh -c \"autoconf\""
        end
      end

      unless uptodate?(File.join(package.build_target, 'Makefile'), [File.join(package.target, 'configure')])
        compiler = DevKitInstaller::COMPILERS[ENV['DKVER']]
        if compiler.host
          # add options for x64
          package.configure_options << "--host=#{compiler.host}"
        end

        cd package.build_target do
          # XXX update regex as required for newer DevKit's
          package.configure_options.push('DLDFLAGS=-static-libgcc') if compiler.version =~ /(?:32|64)\-4\.8\.?\d{0,2}\z/
          sh "sh -c \"#{relative_path}/configure #{package.configure_options.join(' ')} --prefix=#{File.join(RubyInstaller::ROOT, package.install_target)}\""
        end
      end
    end

    task :compile => [:configure, :compiler, :dependencies] do
      cd package.build_target do
        clean = ENV["CLEAN"] ? "clean" : ""
        sh "make #{clean} all"
      end
    end

    task :install => [package.install_target, :dependencies] do
      full_install_target = File.expand_path(File.join(RubyInstaller::ROOT, package.install_target))

      # perform make install
      cd package.build_target do
        sh "make install"
      end

      # copy the DLLs from the listed dependencies
      paths = ENV['PATH'].split(';')
      package.dependencies.each do |dep|
        if dir = paths.find { |p| p =~ /#{dep.to_s}/ }
          Dir.glob("#{File.expand_path(dir)}/*.dll").each do |path|
            next if package.excludes.include?(File.basename(path))
            cp path, File.join(package.install_target, "bin")
          end
        end
      end

      # copy original scripts from ruby_1_8 to install_target
      Dir.glob("#{package.target}/bin/*").each do |path|
        cp path, File.join(package.install_target, "bin")
      end

      # remove path reference to sandbox (after install!!!)
      rbconfig = Dir.glob("#{package.install_target}/lib/**/rbconfig.rb").first
      contents = File.read(rbconfig).gsub(/#{Regexp.escape(full_install_target)}/) { |match| "" }

      # remove sandbox-specific LDFLAGS
      if contents =~ %r{-L\.\s(.*)\"}
        contents.gsub!($1, "")
      end

      # update file
      File.open(rbconfig, 'w') { |f| f.write(contents) }

      # replace the batch files with new and path-clean stubs
      Dir.glob("#{package.install_target}/bin/*.bat").each do |bat|
        File.open(bat, 'w') do |f|
          f.write batch_stub
        end
      end
    end

    task :check => [:compiler] do
      old_gem_home = ENV.delete("GEM_HOME")
      old_gem_path = ENV.delete("GEM_PATH")

      cd package.build_target do
        sh "make check"
      end

      ENV["GEM_HOME"] = old_gem_home if old_gem_home
      ENV["GEM_PATH"] = old_gem_path if old_gem_path
    end

    task :irb do
      cd File.join(package.install_target, 'bin') do
        sh "irb.bat"
      end
    end

    def batch_stub
      <<-SCRIPT
@ECHO OFF
IF NOT "%~f0" == "~f0" GOTO :WinNT
ECHO.This version of Ruby has not been built with support for Windows 95/98/Me.
GOTO :EOF
:WinNT
@"%~dp0ruby.exe" "%~dpn0" %*
SCRIPT
    end
  end
end

desc "compile Ruby 2.1"
task :ruby21 => [
  'interpreter:ruby21:sources',
  'interpreter:ruby21:extract',
  'interpreter:ruby21:prepare',
  'interpreter:ruby21:configure',
  'interpreter:ruby21:compile',
  'interpreter:ruby21:install'
]

namespace :ruby21 do
  task :dependencies => ['interpreter:ruby21:dependencies']
  task :clean => ['interpreter:ruby21:clean']

  task :sh => ['interpreter:ruby21:dependencies'] do
    Rake::Task['devkit:sh'].invoke
  end
end

# Add RubyGems operating system customization
task :ruby21 => ['tools:rubygems:hook21']

# add Pure Readline to the chain
task :ruby21 => [:rbreadline]
task :ruby21 => ['dependencies:rbreadline:install21']

# add tcl/tk installation
unless ENV["NOTK"]
  task :ruby21 => ["dependencies:tk:install21"]
end

task :check21   => ['ruby21:dependencies', 'interpreter:ruby21:check']
task :irb21     => ['ruby21:dependencies', 'interpreter:ruby21:irb']
