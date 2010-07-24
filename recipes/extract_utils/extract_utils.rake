require 'rake/contrib/unzip'

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
  
  task :extract_utils => [:download, package.target] do
    msi_regex = /\.msi$/
    msis = package.files.select { |i| i =~ msi_regex }
    fail 'Only one .msi allowed for RubyInstaller::ExtractUtils.files' if msis.length != 1

    zips = package.files.reject { |i| i =~ msi_regex }

    zips.each do |f|
      filename = "downloads/#{f}"
      Zip.fake_unzip(filename, /\.exe|\.dll$/, package.target)
    end

    # assume 7za.exe can extract individual files from MSI's
    msi = "downloads/#{msis.first}"
    seven_zip_get(msi, '_7z.sfx', package.target)
    File.rename("#{package.target}/_7z.sfx", "#{package.target}/7z.sfx")
  end
end

task :download => ['extract_utils:download']
task :extract_utils => ['extract_utils:extract_utils']
