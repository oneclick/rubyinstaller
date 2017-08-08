require 'rake'
require 'rake/clean'

namespace(:devkit) do
  namespace(:msys) do
    package = DevKitInstaller::MSYS
    directory package.target
    CLEAN.include(package.target)

    dt = checkpoint(:msys, :download)
    package.files.each do |k,v|
      v.each do |f|
        #TODO handle exception when no corresponding URL defined on package
        file_source = "#{package.send(k)}/#{f}"
        file_target = "#{RubyInstaller::DOWNLOADS}/#{f}"
        download file_target => file_source

        # depend on downloads directory
        file file_target => RubyInstaller::DOWNLOADS

        # download task needs the packages files as pre-requisites
        dt.enhance [file_target]
      end
    end
    task :download => [dt]

    # extract each of the packages files into the target dir
    # if archive passes 7-Zip integrity test
    et = checkpoint(:msys, :extract) do
      dt.prerequisites.each do |f|
        fail "[FAIL] corrupt '#{f}' archive" unless seven_zip_valid?(f)
        extract(f, package.target)
      end
    end
    task :extract => [:extract_utils, :download, package.target, et]

    task :prepare do
      #TODO verify whether need to comment out 'cd $HOME' from /etc/profile
    end
  end

  task :msys => ['devkit:msys:download', 'devkit:msys:extract']
end
