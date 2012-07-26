dependencies = RubyInstaller::KNAPSACK_PACKAGES
dkver = ENV['DKVER'] || DevKitInstaller::DEFAULT_VERSION
compiler = DevKitInstaller::COMPILERS[dkver]

dependencies.each do |dependency_key, dependency|
  namespace(:dependencies) do
    namespace(dependency_key) do
      directory dependency.target
      CLEAN.include(dependency.target)

      # Put files for the :download task
      dt = checkpoint(dependency_key, :download)
      dependency.files.each do |f|
        # download x64 files
        f.sub!("-x86-", "-x64-") if compiler.host =~ /x86_64/

        file_source = "#{dependency.url}/#{f}"
        file_target = "downloads/#{f}"
        download file_target => file_source

        # depend on downloads directory
        file file_target => "downloads"

        # download task need these files as pre-requisites
        dt.enhance [file_target]
      end
      task :download => dt

      # Prepare the :sandbox, it requires the :download task
      et = checkpoint(dependency_key, :extract) do
        dt.prerequisites.each { |f|
          extract(File.join(RubyInstaller::ROOT, f), dependency.target)
        }
      end
      task :extract => [:extract_utils, :download, dependency.target, et]

      task :activate => [:extract] do
        puts "Activating #{dependency.human_name} version #{dependency.version}"
        activate(dependency.target)
      end
    end
  end

  task dependency_key => [
    "dependencies:#{dependency_key}:download",
    "dependencies:#{dependency_key}:extract",
    "dependencies:#{dependency_key}:activate"
  ]
end
