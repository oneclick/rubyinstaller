require 'rake'
require 'rake/clean'

namespace(:dependencies) do
  namespace(:git) do
    package = RubyInstaller::Git
    directory package.target
    CLEAN.include(package.target)

    # Put files for the :download task
    dt = checkpoint(:git, :download)
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
    et = checkpoint(:git, :extract) do
      dt.prerequisites.each { |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      }
    end
    task :extract => [:extract_utils, :download, package.target, et]

    task :activate do
      puts "Activating git version #{package.version}"
      activate(package.target)
    end
  end
end

task :git => [
  'dependencies:git:download',
  'dependencies:git:extract',
  'dependencies:git:activate'
]
