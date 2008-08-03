require 'rake'
require 'rake/clean'

namespace(:compiler) do
  namespace(:msys) do
    # mingw needs downloads, sandbox and sandbox/mingw
    package = RubyInstaller::MSYS
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

    # Prepare the :sandbox, it requires the :download task
    task :extract => [:extract_utils, :download, package.target] do
      # grab the files from the download task
      files = Rake::Task['compiler:msys:download'].prerequisites

      files.each { |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      }
    end
    
    # prepares the msys environment to be used
    task :prepare do
      # relocate all content from usr to / since
      # msys is hardcoded to mount /usr and cannot be overwriten
      from_folder = File.join(package.target, "usr")
      Dir.glob("#{from_folder}/*").reject { |f| f =~ /local$/ }.each do |f|
        cp_r f, package.target
      end
      Dir.glob("#{from_folder}/local/*").each do |f|
        cp_r f, package.target
      end
      rm_rf from_folder
      
      # create the fstab file, mount /mingw to sandbox/mingw
      # mount also /usr/local to sandbox/msys/usr
      File.open(File.join(package.target, "etc", "fstab"), 'w') do |f|
        f.puts "#{File.join(RubyInstaller::ROOT, RubyInstaller::MinGW.target)} /mingw"
      end
    
      #remove the chdir to $HOME in the /etc/profile
      profile = File.join(package.target, "etc", "profile")
      
      contents = File.read(profile).gsub(/cd \"\$HOME\"/) do |match|
        "# commented to allow calling from current directory\n##{match}"
      end
      File.open(profile, 'w') { |f| f.write(contents) }
    end
    
    def msys_sh(*args)
      cmd = args.join(' ')
      sh "\"#{File.join(RubyInstaller::ROOT, RubyInstaller::MSYS.target, "bin")}/bash.exe\" --login -i -c \"#{cmd}\""
    end
    
    def msys_system(*args)
      cmd = args.join(' ')
      system "\"#{File.join(RubyInstaller::ROOT, RubyInstaller::MSYS.target, "bin")}/bash.exe\" --login -i -c \"#{cmd}\""
    end
    
  end
end

task :download  => ['compiler:msys:download']
task :extract   => ['compiler:msys:extract']
task :prepare   => ['compiler:msys:prepare']
