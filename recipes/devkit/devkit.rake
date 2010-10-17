begin
  require 'erubis/tiny'
  DkEruby = Erubis::TinyEruby
rescue LoadError
  require 'erb'
  DkEruby = ERB
end

CLEAN.include(DevKitInstaller::DevKit.inno_config)

directory 'pkg'

namespace(:devkit) do

  # canonicalize DevKit compiler version and check if version is supported
  ENV['DKVER'] = ENV['DKVER'].nil? ? DevKitInstaller::DEFAULT_VERSION.downcase : ENV['DKVER'].downcase
  fail '[FAIL] invalid DKVER value provided' unless DevKitInstaller::VALID_COMPILERS.include?(ENV['DKVER'])

  # build Inno Setup script file from template
  file DevKitInstaller::DevKit.inno_config => [DevKitInstaller::DevKit.inno_config_erb] do |t|
    # template data
    guid = DevKitInstaller::DevKit.installer_guid
    dk_version = ENV['DKVER']

    content = DkEruby.new(File.read(t.prerequisites.first)).result(binding)
    File.open(t.name, 'w') { |f| f.write(content) }
  end

  task :installer, [:target] => [DevKitInstaller::DevKit.inno_config, :innosetup] do |t, args|
    InnoSetup.iscc(DevKitInstaller::DevKit.inno_script,
      :output => 'pkg',
      :filename => "#{args.target}"
    )
  end

  # Prepend DevKit to the PATH and setup name prefixed build executables
  task :env => ['devkit:msys', 'devkit:mingw'] do
    msys = DevKitInstaller::MSYS
    mingw = DevKitInstaller::COMPILERS[ENV['DKVER']]
    fail '[FAIL] unable to find correct MinGW version config' unless mingw

    msys_path = File.join(RubyInstaller::ROOT, msys.target).gsub(File::SEPARATOR, File::ALT_SEPARATOR)
    mingw_path = File.join(RubyInstaller::ROOT, mingw.target).gsub(File::SEPARATOR, File::ALT_SEPARATOR)

    unless ENV['PATH'].include?("#{mingw_path}\\bin")
      puts 'Temporarily enhancing PATH to include DevKit...'
      ENV['PATH'] = "#{msys_path}\\bin;#{mingw_path}\\bin;" + ENV['PATH']
    end

    # TODO move ENV updates to an 'activate' task
    # TODO check mingw-w64 (32-bit) binaries for existing {gcc,g++,cpp}.exe conflicts
    # TODO update operating_system.rb/devkit.rb at DevKit build time for ENV vars
    if mingw.program_prefix
      ['CC','CXX','CPP'].zip([:gcc,:'g++',:cpp]) do |exe|
        ENV[exe[0]] = "#{mingw.program_prefix}-#{exe[1]}" if mingw.programs.include?(exe[1])
      end
    end
  end
end

desc 'build DevKit installer and 7z archives.'
task :devkit => ['devkit:msys', 'devkit:mingw', 'pkg'] do |t|
  sevenz_archive = ENV['7Z'] ? true : false
  sevenz_sfx = ENV['SFX'] ? true : false

  archive_base = "DevKit-#{ENV['DKVER']}-#{Time.now.strftime('%Y%m%d-%H%M')}"

  # copy helper scripts to DevKit sandbox
  DevKitInstaller::DevKit.setup_scripts.each do |s|
    FileUtils.cp(File.join(RubyInstaller::ROOT, 'resources', 'devkit', s),
              'sandbox/devkit')
  end

  # build a 7-Zip archive and/or a self-extracting archive
  Dir.chdir('sandbox/devkit') do

    seven_zip_build('*',
                    File.join(RubyInstaller::ROOT, 'pkg', "#{archive_base}.7z"))

    if sevenz_sfx
      Dir.chdir(RubyInstaller::ROOT) do
        cmd = 'copy /b %s + %s %s' % [
          'sandbox\extract_utils\7z.sfx',
          "pkg\\#{archive_base}.7z",
          "pkg\\#{archive_base}-sfx.exe"
        ]
        sh "#{cmd} > NUL"
      end
    end

  end if sevenz_archive || sevenz_sfx

  # build a Windows Installer
  # TODO enable after finishing DevKit GUI code
  #Rake::Task['devkit:installer'].invoke(archive_base)

end
