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
    archive_base = "DevKit-#{ENV['DKVER']}-#{Time.now.strftime('%Y%m%d-%H%M')}"

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
end
