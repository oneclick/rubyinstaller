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
      # rebase dll to prevent errors at fork
      rebase = File.join(RubyInstaller::ROOT, DevKitInstaller::MSYS.target, 'usr', 'bin', 'rebase.exe')
      dll = File.join(RubyInstaller::ROOT, DevKitInstaller::MSYS.target, 'usr', 'bin', 'msys-unistring-2.dll')
      sh rebase, '-b 0x65000000', dll
    end
    task :prepare => [:extract, pt]
  end

  task :msys => ['devkit:msys:download', 'devkit:msys:extract', 'devkit:msys:prepare']
end
