require 'rake/contrib/unzip.rb'

namespace(:extract_utils) do
  package = RubyInstaller::ExtractUtils
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
  
  task :extract_utils => [:download, package.target, "dependencies:zlib:download"] do
    package.files.each do |f|
      filename = "downloads/#{f}"
      Zip.fake_unzip(filename, /\.exe|\.dll$/, package.target)
    end
    RubyInstaller::Zlib.files.each do |f|
      filename = "downloads/#{f}"
      Zip.fake_unzip(filename, /\.exe|\.dll$/, package.target)
    end
  end
end

task :download => ['extract_utils:download']
task :extract_utils => ['extract_utils:extract_utils']
