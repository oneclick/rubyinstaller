require 'rake'
require 'rake/clean'

namespace(:dependencies) do
  namespace(:gdbm) do
    package = RubyInstaller::Gdbm
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
      files = Rake::Task['dependencies:gdbm:download'].prerequisites

      files.each { |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      }
    end
    
    task :prepare => [package.target] do
      # gdbm needs some adjustments.
      # move gdbm-dll.h from source to include
      cd File.join(RubyInstaller::ROOT, package.target) do
        files = Dir.glob(File.join('src', 'gdbm', '*', 'gdbm-*-src', 'gdbm-dll.h'))
        fail "Multiple gdbm-dll.h files found." unless files.size == 1
        gdbm_dll_h = files[0]
        cp gdbm_dll_h, 'include'
      end
    end
  end
end

task :download  => ['dependencies:gdbm:download']
task :extract   => ['dependencies:gdbm:extract']
task :prepare   => ['dependencies:gdbm:prepare']
