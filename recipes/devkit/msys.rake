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
        file_target = "downloads/#{f}"
        download file_target => file_source

        # depend on downloads directory
        file file_target => "downloads"

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
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      end
    end
    task :extract => [:extract_utils, :download, package.target, et]

    pt = checkpoint(:msys, :prepare) do
      # check if package define 'relocate'
      # A package that defines it will trigger move of all the inner folders of the mentioned folder
      # to the original package target.
      if package.relocate && Dir.exist?(package.relocate)
        folders = []
        Dir.chdir(package.relocate) { folders = Dir.glob("*") }

        folders.each do |folder|
          puts "** Moving out #{folder} from #{package.relocate} and drop into #{package.target}" if Rake.application.options.trace
          mv_r File.join(package.relocate, folder), package.target
        end

        # remove folder
        rm_r package.relocate
      end
    end
    task :prepare => [:extract, pt]
  end

  task :msys => ['devkit:msys:download', 'devkit:msys:extract', 'devkit:msys:prepare']
end
