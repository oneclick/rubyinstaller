require 'rake'
require 'rake/clean'

namespace(:interpreter) do
  namespace(:ruby18) do
    package = RubyInstaller::Ruby18
    directory package.target
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
      Dir.chdir(RubyInstaller::ROOT) do
        # If is there already a checkout, update instead of checkout"
        if File.exist?(File.join(RubyInstaller::ROOT, package.checkout_target, '.svn'))
          sh "svn update #{package.checkout_target}"
        else
          sh "svn co #{package.checkout} #{package.checkout_target}"
        end
      end
    end

    task :extract => [:extract_utils, package.target] do
      # grab the files from the download task
      files = Rake::Task['interpreter:ruby18:download'].prerequisites

      # use the checkout copy instead of the packaged file
      unless ENV['CHECKOUT']
        files.each { |f|
          extract(File.join(RubyInstaller::ROOT, f), package.target)
        }
      else
        FileUtils.cp_r(package.checkout_target, File.join(RubyInstaller::ROOT, 'sandbox'), :verbose => true)
      end
    end
    ENV['CHECKOUT'] ? task(:extract => :checkout) : task(:extract => :download)
    
    task :prepare => [package.build_target] do
      Dir.chdir(RubyInstaller::ROOT) do
        FileUtils.cp_r(Dir.glob('resources/icons/*.ico'), package.build_target, :verbose => true)
      end
    end

    task :configure => [package.target, package.build_target] do
      # check for configure script existance or checkout being used.
      if File.exist?(File.join(package.target, '.svn')) or !File.exist?(File.join(package.target, 'configure'))
        Dir.chdir(package.target) do
          msys_sh "autoconf"
        end
      end
      Dir.chdir(package.build_target) do
        msys_sh "../ruby_1_8/configure #{package.configure_options.join(' ')} --prefix=#{File.join(RubyInstaller::ROOT, package.install_target)}"
      end
    end

    task :compile do
      Dir.chdir(package.build_target) do
        msys_sh "make"
      end
    end

    task :install => [package.install_target] do
      full_install_target = File.expand_path(File.join(RubyInstaller::ROOT, package.install_target))
      
      # perform make install
      Dir.chdir(package.build_target) do
        msys_sh "make install"
      end
      
      # verbatim copy the binaries listed in package.dependencies
      package.dependencies.each do |dep|
        Dir.glob("#{RubyInstaller::MinGW.target}/**/#{dep}").each do |f|
          FileUtils.cp(f, File.join(package.install_target, "bin"))
        end
      end
      
      # copy original scripts from ruby_1_8 to install_target
      Dir.glob("#{package.target}/bin/*").each do |f|
        FileUtils.cp(f, File.join(package.install_target,"bin"))
      end

      # remove path reference to sandbox (after install!!!)
      rbconfig = File.join(package.install_target, 'lib/ruby/1.8/i386-mingw32/rbconfig.rb')
      contents = File.read(rbconfig).gsub(/#{Regexp.escape(full_install_target)}/) { |match| "" }
      File.open(rbconfig, 'w') { |f| f.write(contents) }
    end

    # makes the installed ruby the first in the path and use if for the tests!
    task :check do
      new_ruby = File.join(RubyInstaller::ROOT, package.install_target, "bin").gsub(File::SEPARATOR, File::ALT_SEPARATOR)
      ENV['PATH'] = "#{new_ruby};#{ENV['PATH']}"
      Dir.chdir(package.build_target) do
        msys_sh "make check"
      end
    end

    task :manifest do
      manifest = File.open(File.join(package.build_target, "manifest"), 'w')
      Dir.chdir(package.install_target) do
        Dir.glob("**/*").each do |f|
          manifest.puts(f) unless File.directory?(f)
        end
      end
      manifest.close
    end

    task :irb do
      Dir.chdir(File.join(package.install_target, 'bin')) do
        sh "irb"
      end
    end
  end
end

if ENV['CHECKOUT']
  task :download  => ['interpreter:ruby18:checkout']
else
  task :download  => ['interpreter:ruby18:download']
end
task :extract   => ['interpreter:ruby18:extract']
task :prepare   => ['interpreter:ruby18:prepare']
task :configure => ['interpreter:ruby18:configure']
task :compile   => ['interpreter:ruby18:compile']
task :install   => ['interpreter:ruby18:install']
task :check     => ['interpreter:ruby18:check']
task :irb       => ['interpreter:ruby18:irb']
