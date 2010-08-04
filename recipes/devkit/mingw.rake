require 'rake'
require 'rake/clean'

namespace(:devkit) do
  namespace(:mingw) do
    ENV['DKVER'] ||= '4.5.0'

    package = nil
    DevKitInstaller::MinGWs.each do |m|
      package = m if m.version == ENV['DKVER']
    end
    fail '[FAIL] unable to find correct MinGW version config' if package.nil?

    directory package.target
    CLEAN.include(package.target)

    package.files.each do |k,v|
      v.each do |f|
        #TODO handle exception when no corresponding URL defined on package
        file_source = "#{package.send(k)}/#{f}"
        file_target = "downloads/#{f}"
        download file_target => file_source

        # depend on downloads directory
        file file_target => "downloads"

        # download task needs the packages files as pre-requisites
        task :download => file_target
      end
    end

    task :extract => [:extract_utils, :download, package.target] do
      # extract each of the packages files into the target dir
      # if archive passes 7-Zip integrity test
      Rake::Task['devkit:mingw:download'].prerequisites.each do |f|
        fail "[FAIL] corrupt '#{f}' archive" unless seven_zip_valid?(f)
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      end
    end

  end

  task :mingw => ['devkit:msys']
  task :mingw => ['devkit:mingw:download', 'devkit:mingw:extract']
end
