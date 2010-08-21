require 'rake'
require 'rake/clean'

namespace(:interpreter) do
  namespace(:ruby18) do
    package = RubyInstaller::Ruby18
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

    task :sources do
      case
      when ENV['LOCAL']
      when ENV['CHECKOUT']
        Rake::Task['interpreter:ruby18:checkout'].invoke
      else
        Rake::Task['interpreter:ruby18:download'].invoke
      end
    end

    task :extract => [:extract_utils] do
      case
      when ENV['LOCAL']
        package.target = File.expand_path(File.join(ENV['LOCAL'], '.'))
      when ENV['CHECKOUT']
        package.target = File.expand_path(package.checkout_target)
      else
        # grab the files from the download task
        files = Rake::Task['interpreter:ruby18:download'].prerequisites

        # ensure target directory exist
        mkdir_p package.target

        files.each { |f|
          extract(File.join(RubyInstaller::ROOT, f), package.target)
        }
      end
    end

    task :prepare => [package.build_target, *package.dependencies] do
      cd RubyInstaller::ROOT do
        cp_r(Dir.glob('resources/icons/*.ico'), package.build_target, :verbose => true)
      end
    end

    task :configure => [package.build_target, :compiler, *package.dependencies] do
      source_path = Pathname.new(File.expand_path(package.target))
      build_path = Pathname.new(File.expand_path(package.build_target))

      relative_path = source_path.relative_path_from(build_path)

      # working with a checkout, generate configure
      unless File.exist?(File.join(package.target, 'configure'))
        cd package.target do
          sh "sh -c \"autoconf\""
        end
      end

      cd package.build_target do
        sh "sh -c \"#{relative_path}/configure #{package.configure_options.join(' ')} --prefix=#{File.join(RubyInstaller::ROOT, package.install_target)}\""
      end
    end

    task :compile => [:configure, :compiler, *package.dependencies] do
      cd package.build_target do
        sh "make"
      end
    end

    task :install => [ package.install_target, *package.dependencies ] do
      full_install_target = File.expand_path(File.join(RubyInstaller::ROOT, package.install_target))
      full_install_target_nodrive = full_install_target.gsub(/\A[a-z]:/i, '')

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
      File.open(rbconfig, 'w') { |f| f.write(contents) }

      # replace the batch files with new and path-clean stubs
      Dir.glob("#{package.install_target}/bin/*.bat").each do |bat|
        File.open(bat, 'w') do |f|
          f.write batch_stub
        end
      end

      rbconfig = File.join(package.install_target, 'lib/ruby/1.8/i386-mingw32/rbconfig.rb')
      contents = File.read(rbconfig).
        gsub(/#{Regexp.escape(full_install_target)}/) { |match| "" }.
        gsub(/#{Regexp.escape(full_install_target_nodrive)}/) { |match| "" }.
        gsub('$(DESTDIR)', '$(exec_prefix)').
        gsub('CONFIG["exec_prefix"] = "$(exec_prefix)"', 'CONFIG["exec_prefix"] = "$(prefix)"')

      File.open(rbconfig, 'w') { |f| f.write(contents) }

      # replace the batch files with new and path-clean stubs
      Dir.glob("#{package.install_target}/bin/*.bat").each do |bat|
        File.open(bat, 'w') do |f|
          f.write batch_stub
        end
      end
    end

    # makes the installed ruby the first in the path and use if for the tests!
    task :check do
      new_ruby = File.join(RubyInstaller::ROOT, package.install_target, "bin").gsub(File::SEPARATOR, File::ALT_SEPARATOR)
      ENV['PATH'] = "#{new_ruby};#{ENV['PATH']}"
      cd package.build_target do
        msys_sh "make check"
      end
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

desc "compile Ruby 1.8"
task :ruby18 => [
  'interpreter:ruby18:sources',
  'interpreter:ruby18:extract',
  'interpreter:ruby18:prepare',
  'interpreter:ruby18:configure',
  'interpreter:ruby18:compile',
  'interpreter:ruby18:install'
]

# Add rubygems to the chain
task :ruby18 => [:rubygems18]

# add Pure Readline to the chain
task :ruby18 => [:rbreadline]
task :ruby18 => ['dependencies:rbreadline:install18']

task :check18 => ['interpreter:ruby18:check']
task :irb18   => ['interpreter:ruby18:irb']
