require 'rake/contrib/unzip'

namespace(:extract_utils) do
  package = RubyInstaller::ExtractUtils
  directory package.target
  CLEAN.include(package.target)

  # Put files for the :download task
  package.files.each do |k,v|
    v.each do |f|
      #TODO handle exception when no corresponding URL defined on package
      file_source = "#{package.send(k)}/#{f}"
      file_target = "#{RubyInstaller::DOWNLOADS}/#{f}"
      download file_target => file_source

      # depend on downloads directory
      file file_target => RubyInstaller::DOWNLOADS

      # download task need these files as pre-requisites
      task :download => file_target
    end
  end

  task :extract_utils => [:download, package.target] do
    msi_regex = /\.msi$/
    msis = []
    zips = []

    package.files.each do |k,v|
      v.each do |f|
        msis << f if f =~ msi_regex
        zips << f unless f =~ msi_regex
      end
    end
    fail 'Only one .msi allowed for RubyInstaller::ExtractUtils.files' if msis.length != 1

    zips.each do |f|
      filename = "#{RubyInstaller::DOWNLOADS}/#{f}"
      Zip.fake_unzip(filename, /\.exe|\.dll$/, package.target)
    end

    # assume 7za.exe can extract individual files from MSI's
    unless File.exist?("#{package.target}/7z.sfx")
      msi = "#{RubyInstaller::DOWNLOADS}/#{msis.first}"
      seven_zip_get(msi, '_7z.sfx', package.target)
      File.rename("#{package.target}/_7z.sfx", "#{package.target}/7z.sfx")
    end
  end
end

task :download => ['extract_utils:download']
task :extract_utils => ['extract_utils:extract_utils']
