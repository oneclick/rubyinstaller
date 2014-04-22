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
  ['CC','CXX','CPP','WINDRES'].zip([:gcc,:'g++',:cpp,:windres]) do |exe|
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
  fail '[FAIL] invalid DKVER value provided' unless DevKitInstaller::COMPILERS.has_key?(ENV['DKVER'])

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

    ENV['MSYSTEM'] = 'MINGW32'

    # TODO remove as this env var override style will no longer be supported
    # Fragile --host alternative that currently allows the llvm-gcc and i686-w64-mingw32
    # toolchains to build deps and Ruby using their name prefixed tools, if applicable.
    if mingw.program_prefix
      ['CC','CPP','CXX','WINDRES','AR','AS','NM','RANLIB','OBJDUMP','OBJCOPY','STRIP','DLLWRAP','DLLTOOL'].zip(
        [:gcc,:cpp,:'g++',:windres,:ar,:as,:nm,:ranlib,:objdump,:objcopy,:strip,:dllwrap,:dlltool]) do |exe|
        ENV[exe[0]] = "#{mingw.program_prefix}-#{exe[1]}" if mingw.programs.include?(exe[1])
      end
    end
  end

  task :sh => [:activate] do
    sh_exe = File.join(RubyInstaller::ROOT, DevKitInstaller::MSYS.target, 'bin', 'sh.exe')
    exec sh_exe
  end

  desc 'List available DevKit flavors'
  task :ls do
    compilers = DevKitInstaller::COMPILERS.keys.sort.map(&:downcase)
    default = DevKitInstaller::DEFAULT_VERSION.downcase
    current = ENV['DKVER'] || default
    current = current.downcase

    puts "\n=== Available DevKit's ==="
    max_len = compilers.map(&:length).max
    compilers.each do |k|
      puts " %-2s %-#{max_len+1}s %s" % [
        current == k ? '=>' : nil,
        k,
        default == k ? '[default]' : nil
      ]
    end
  end

  task :build => ['devkit:msys', 'devkit:mingw', DevKitInstaller::DevKit.install_script, 'pkg'] do |t|
    # copy helper scripts to DevKit sandbox
    DevKitInstaller::DevKit.setup_scripts.each do |s|
      FileUtils.cp(File.join(RubyInstaller::ROOT, 'resources', 'devkit', s),
                   'sandbox/devkit')
    end
  end

  # Devkit packing vars
  archive_base = "DevKit-#{ENV['DKVER']}-#{Time.now.strftime('%Y%m%d-%H%M')}"

  task :zip => [:build] do
    # build a 7-Zip archive and/or a self-extracting archive
    Dir.chdir('sandbox/devkit') do
      seven_zip_build('*',
                      File.join(RubyInstaller::ROOT, 'pkg', "#{archive_base}.7z"))
    end
  end

  task :sfx => [:zip] do
    Dir.chdir(RubyInstaller::ROOT) do
      cmd = 'copy /b %s + %s %s' % [
        'sandbox\extract_utils\7z.sfx',
        "pkg\\#{archive_base}.7z",
        "pkg\\#{archive_base}-sfx.exe"
      ]
      sh "#{cmd} > NUL"
    end
  end
end

desc 'Build DevKit installer and/or archives.'
task :devkit => ['devkit:build']

if ENV['7Z']
  task :devkit => ['devkit:zip']
end

if ENV['SFX']
  task :devkit => ['devkit:sfx']
end

  # build a Windows Installer
  # TODO enable after finishing DevKit GUI code
  #Rake::Task['devkit:installer'].invoke(archive_base)
