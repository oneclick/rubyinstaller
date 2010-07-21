directory 'pkg'

desc 'build DevKit installer and 7z archive.'
task :devkit => ['devkit:msys', 'devkit:mingw', 'pkg'] do
  sevenz_archive = ENV['7Z'] ? true : false


  # copy helper scripts to DevKit sandbox
  DevKitInstaller::DevKit.setup_scripts.each do |s|
    FileUtils.cp(File.join(RubyInstaller::ROOT, 'resources', 'devkit', s),
              'sandbox/devkit')
  end

  Dir.chdir('sandbox/devkit') do
    seven_zip_build(
      '*',
      File.join(RubyInstaller::ROOT,
                'pkg',
                "DevKit-#{ENV['DKVER']}-#{Time.now.strftime('%Y%m%d')}.7z"
      )
    )
  end if sevenz_archive
end
