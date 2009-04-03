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
      # create the fstab file, mount /mingw to sandbox/mingw
      # mount also /usr/local to sandbox/msys/usr/local
      mingw = File.join(RubyInstaller::ROOT, RubyInstaller::MinGW.target)
      usr_local = File.join(RubyInstaller::ROOT, package.target, 'usr', 'local')

      File.open(File.join(package.target, "etc", "fstab"), 'w') do |f|
        f.puts "#{mingw} /mingw"
        f.puts "#{usr_local} /usr/local"
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

# depend on mingw part
task :msys => [:mingw]
task :msys => ['compiler:msys:download', 'compiler:msys:extract', 'compiler:msys:prepare']

# compiler also depends on msys
task :compiler => [:msys]
