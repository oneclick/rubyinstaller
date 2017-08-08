require 'rake'
require 'rake/clean'

namespace(:devkit) do
  namespace(:mingw) do
    package = DevKitInstaller::COMPILERS[ENV['DKVER']]
    fail '[FAIL] unable to find correct DevKit compiler version configuration' unless package

    directory package.target
    CLEAN.include(package.target)

    dt = checkpoint(:mingw, :download)
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
    task :download => dt

    # extract each of the packages files into the target dir
    # if archive passes 7-Zip integrity test
    et = checkpoint(:mingw, :extract) do
      dt.prerequisites.each do |f|
        fail "[FAIL] corrupt '#{f}' archive" unless seven_zip_valid?(f)
        extract(f, package.target)
      end
    end
    task :extract => [:extract_utils, :download, package.target, et]

    # check if package define 'relocate'
    # A package that defines it will trigger move of all the inner folders of the mentioned folder
    # to the original package target.
    #
    # This is used to successfully extract rubenvb mingw-w64 builds for devkit.
    if package.relocate
      pt = checkpoint(:mingw, :prepare) do
        folders = []
        Dir.chdir(package.relocate) { folders = Dir.glob("*") }

        folders.each do |folder|
          puts "** Moving out #{folder} from #{package.relocate} and drop into #{package.target}" if Rake.application.options.trace
          mv_r File.join(package.relocate, folder), package.target
        end

        # remove folder
        rm_r package.relocate
      end
      task :prepare => [:extract, pt]
    else
      # noop
      task :prepare => [:extract]
    end
  end

  task :mingw => ['devkit:msys']
  task :mingw => ['devkit:mingw:download', 'devkit:mingw:extract', 'devkit:mingw:prepare']
end
