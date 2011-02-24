require 'rake'
require 'rake/clean'

namespace(:dependencies) do
  namespace(:pango) do
    package = RubyInstaller::Pango
    directory package.target
    CLEAN.include(package.target)

    # Put files for the :download task
    dt = checkpoint(:pango, :download)
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
    et = checkpoint(:pango, :extract) do
      dt.prerequisites.each { |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      }
      package.files.each {|f|
        extract(File.join(RubyInstaller::ROOT, "downloads", f), package.target)
      }
    end
    task :extract => [:extract_utils, :download, package.target, et]

    task :activate do
      puts "Activating pango version #{package.version}"
      activate(package.target)
    end
  end
end

task :pango => [
  'dependencies:pango:download',
  'dependencies:pango:extract',
  'dependencies:pango:activate'
]
