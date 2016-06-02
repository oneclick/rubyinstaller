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

      if compiler.host =~ /x86_64/
        files = dependency.x64_files
        if compiler.knap_path
          files_url = "#{dependency.url}/#{compiler.knap_path}/x64"
        else
        files_url = "#{dependency.url}/x64"
        end
      else
        files = dependency.files
        if compiler.knap_path
          files_url = "#{dependency.url}/#{compiler.knap_path}/x86"
        else
        files_url = "#{dependency.url}/x86"
      end
      end

      download_path = RubyInstaller::DOWNLOADS
      if compiler.knap_path
        download_path = "#{download_path}/#{compiler.knap_path}"
      end

      files.each do |f|
        file_source = "#{files_url}/#{f}"
        file_target = "#{download_path}/#{f}"
        download file_target => file_source

        # depend on downloads directory
        file file_target => "#{download_path}"
        directory "#{download_path}"

        # download task need these files as pre-requisites
        dt.enhance [file_target]
      end
      task :download => dt

      # Prepare the :sandbox, it requires the :download task
      et = checkpoint(dependency_key, :extract) do
        dt.prerequisites.each { |f|
          extract(f, dependency.target)
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
