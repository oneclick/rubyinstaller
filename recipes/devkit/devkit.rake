directory 'pkg'

desc 'build DevKit installer and 7z archive.'
task :devkit => ['devkit:msys', 'devkit:mingw', 'pkg'] do
  sevenz_archive = ENV['7Z'] ? true : false
  sevenz_sfx = ENV['SFX'] ? true : false

  # copy helper scripts to DevKit sandbox
  DevKitInstaller::DevKit.setup_scripts.each do |s|
    FileUtils.cp(File.join(RubyInstaller::ROOT, 'resources', 'devkit', s),
              'sandbox/devkit')
  end

  # build a 7-Zip archive and/or a self-extracting archive
  Dir.chdir('sandbox/devkit') do
    seven_zip_build(
      '*',
      File.join(RubyInstaller::ROOT,
                'pkg',
                "DevKit-#{ENV['DKVER']}-#{Time.now.strftime('%Y%m%d')}.7z"
      )
    ) if sevenz_archive

    seven_zip_build(
      '*',
      File.join(RubyInstaller::ROOT, 'pkg',
                "DevKit-#{ENV['DKVER']}-#{Time.now.strftime('%Y%m%d')}-sfx.exe"),
      :sfx => true
    ) if sevenz_sfx

  end if sevenz_archive || sevenz_sfx
end
