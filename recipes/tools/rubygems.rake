require 'rake'
require 'rake/clean'

namespace(:tools) do
  namespace(:rubygems) do
    package = RubyInstaller::RubyGems
    directory package.target
    CLEAN.include(package.target)
    
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

    # Prepare the :sandbox, it requires the :download task
    task :extract => [:extract_utils, package.target] do
      # grab the files from the download task
      files = Rake::Task['tools:rubygems:download'].prerequisites

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
    
    task :install => [package.target, package.install_target] do
      new_ruby = File.join(RubyInstaller::ROOT, package.install_target, "bin").gsub(File::SEPARATOR, File::ALT_SEPARATOR)
      ENV['PATH'] = "#{new_ruby};#{ENV['PATH']}"
      Dir.chdir(package.target) do
        sh "ruby setup.rb install #{package.configure_options.join(' ')}"
      end
      
      # now fixes all the stub batch files form bin
      Dir.glob("#{package.install_target}/bin/*.bat").each do |bat|
        script = File.basename(bat).gsub(File.extname(bat), '')
        File.open(bat, 'w') do |f|
          f.puts <<-TEXT
@ECHO OFF
IF NOT "%~f0" == "~f0" GOTO :WinNT
@"ruby.exe" "#{File.join("C:/Ruby/bin", script)}" %1 %2 %3 %4 %5 %6 %7 %8 %9
GOTO :EOF
:WinNT
@"ruby.exe" "%~dpn0" %*
TEXT
        end
      end
      
      # and now, fixes the shebang lines for the scripts
      bang_line = "#!#{File.expand_path(File.join(package.install_target, 'bin', 'ruby.exe'))}"
      Dir.glob("#{package.install_target}/bin/*").each do |script|
        # only process true scripts!!! (extensionless)
        if File.extname(script) == ""
          contents = File.read(script).gsub(/#{Regexp.escape(bang_line)}/) do |match|
            "#!/usr/bin/env ruby"
          end
          File.open(script, 'w') { |f| f.write(contents) }
        end
      end
    end
  end
end


if ENV['CHECKOUT']
  task :download  => ['tools:rubygems:checkout']
else
  task :download  => ['tools:rubygems:download']
end
task :extract   => ['tools:rubygems:extract']
task :install   => ['tools:rubygems:install']
