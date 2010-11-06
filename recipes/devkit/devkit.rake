require 'erb'

CLEAN.include(DevKitInstaller::DevKit.inno_config)
CLEAN.include(DevKitInstaller::DevKit.install_script)

directory 'pkg'

# build Ruby-based DevKit installer script file from template
file DevKitInstaller::DevKit.install_script => [DevKitInstaller::DevKit.install_script_erb] do |t|
  mingw = DevKitInstaller::COMPILERS[ENV['DKVER']]
  fail '[FAIL] unable to find correct MinGW version config' unless mingw

  # build ENV tool name template data
  tool_names = {}
  ['CC','CXX','CPP'].zip([:gcc,:'g++',:cpp]) do |exe|
    prefix = mingw.program_prefix.nil? ? nil : "#{mingw.program_prefix}-"
    tool_names[exe[0]] = "#{prefix}#{exe[1]}" if mingw.programs.include?(exe[1])
  end

  content = ERB.new(File.read(t.prerequisites.first), 0, '-').result(binding)
  File.open(t.name, 'w') { |f| f.write(content) }
end

# build Inno Setup script file from template
file DevKitInstaller::DevKit.inno_config => [DevKitInstaller::DevKit.inno_config_erb] do |t|
  # template data
  guid = DevKitInstaller::DevKit.installer_guid
  dk_version = ENV['DKVER']

  content = ERB.new(File.read(t.prerequisites.first)).result(binding)
  File.open(t.name, 'w') { |f| f.write(content) }
end


namespace(:devkit) do

  # canonicalize DevKit compiler version and check if version is supported
  ENV['DKVER'] = ENV['DKVER'].nil? ? DevKitInstaller::DEFAULT_VERSION.downcase : ENV['DKVER'].downcase
  fail '[FAIL] invalid DKVER value provided' unless DevKitInstaller::VALID_COMPILERS.include?(ENV['DKVER'])

  task :installer, [:target] => [DevKitInstaller::DevKit.inno_config, :innosetup] do |t, args|
    InnoSetup.iscc(DevKitInstaller::DevKit.inno_script,
      :output => 'pkg',
      :filename => "#{args.target}"
    )
  end

  # Prepend DevKit to the PATH and inject prefixed toolchain executable names
  # into ENV to support alternative compiler tools
  task :activate => ['devkit:msys', 'devkit:mingw'] do
    msys = DevKitInstaller::MSYS
    mingw = DevKitInstaller::COMPILERS[ENV['DKVER']]
    fail '[FAIL] unable to find correct MinGW version config' unless mingw

    msys_path = File.join(RubyInstaller::ROOT, msys.target).gsub(File::SEPARATOR, File::ALT_SEPARATOR)
    mingw_path = File.join(RubyInstaller::ROOT, mingw.target).gsub(File::SEPARATOR, File::ALT_SEPARATOR)

    unless ENV['PATH'].include?("#{mingw_path}\\bin")
      puts 'Temporarily enhancing PATH to include DevKit...'
      ENV['PATH'] = "#{msys_path}\\bin;#{mingw_path}\\bin;" + ENV['PATH']
    end

    if mingw.program_prefix
      ['CC','CXX','CPP'].zip([:gcc,:'g++',:cpp]) do |exe|
        ENV[exe[0]] = "#{mingw.program_prefix}-#{exe[1]}" if mingw.programs.include?(exe[1])
      end
    end
  end
end


desc 'Build DevKit installer and/or archives.'
task :devkit => ['devkit:msys', 'devkit:mingw', DevKitInstaller::DevKit.install_script, 'pkg'] do |t|
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
