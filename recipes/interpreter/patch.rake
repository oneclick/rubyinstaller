require 'rake'
require 'rake/clean'

namespace(:interpreter) do
  namespace(:patch) do
    package = RubyInstaller::Patches
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
    
    task :extract => [:extract_utils, :download, package.target] do
      # grab the files from the download task
      files = Rake::Task['interpreter:patch:download'].prerequisites

      files.each do |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      end
    end
    
    task :prepare => [package.prepare_target] do
      glob = File.join(RubyInstaller::ROOT, package.target, '*.patch')
      cd package.prepare_target do
        Dir[glob].sort.each do |patch|
          msys_sh "patch -p1 -t < #{patch}"
        end
      end
    end  
  
  end
end

unless ENV['CHECKOUT']
  task :download  => ['interpreter:patch:download']
  task :extract   => ['interpreter:patch:extract']
  task :prepare   => ['interpreter:patch:prepare'] 
end
