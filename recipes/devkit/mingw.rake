require 'rake'
require 'rake/clean'

namespace(:devkit) do
  dk_version = ENV['DKVER'] ||= DevKitInstaller::DEFAULT_VERSION

  namespace(:mingw) do
    package = DevKitInstaller::MinGWs.find { |m| m.version == dk_version }
    fail '[FAIL] unable to find correct MinGW version config' unless package

    directory package.target
    CLEAN.include(package.target)

    dt = checkpoint(:mingw, :download)
    package.files.each do |k,v|
      v.each do |f|
        #TODO handle exception when no corresponding URL defined on package
        file_source = "#{package.send(k)}/#{f}"
        file_target = "downloads/#{f}"
        download file_target => file_source

        # depend on downloads directory
        file file_target => "downloads"

        # download task needs the packages files as pre-requisites
        dt.enhance [file_target]
      end
    end
    task :download => dt

    # extract each of the packages files into the target dir
    # if archive passes 7-Zip integrity test
    et = checkpoint(:mingw, :extract) do
      dt.prerequisites.each do |f|
        fail "[FAIL] corrupt '#{f}' archive" unless seven_zip_valid?(f)
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      end
    end
    task :extract => [:extract_utils, :download, package.target, et]
  end

  task :mingw => ['devkit:msys']
  task :mingw => ['devkit:mingw:download', 'devkit:mingw:extract']
end
