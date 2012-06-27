dependencies = RubyInstaller::KNAPSACK_PACKAGES

dependencies.each do |dependency_key, dependency|
  namespace(:dependencies) do
    namespace(dependency_key) do
      directory dependency.target
      CLEAN.include(dependency.target)

      # Put files for the :download task
      dt = checkpoint(dependency_key, :download)
      dependency.files.each do |f|
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

      task :patch => [:extract] do
        if dependency_key == 'openssl'
          openssl_base = File.join(RubyInstaller::ROOT, dependency.target)
          conf_file = File.join(openssl_base, "include/openssl/opensslconf.h")
          content = File.open(conf_file, "rb") { |f| f.read }

          if content
            ssl_dir = content.sub(/.*\n#define OPENSSLDIR "([^\n]*)"\n.*/m, '\1')
          end

          if ssl_dir && !File.exist?(File.join(ssl_dir, "openssl.cnf"))
            mkdir_p ssl_dir
            cp File.join(openssl_base, "ssl/openssl.cnf"), ssl_dir
          end
        end
      end

      task :activate => [:extract, :patch] do
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
