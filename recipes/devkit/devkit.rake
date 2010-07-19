directory 'pkg'

desc 'build DevKit installer and 7z archive.'
task :devkit => ['devkit:msys', 'devkit:mingw', 'pkg'] do
  sevenz_archive = ENV['7Z'] ? true : false


  # copy helper scripts to DevKit sandbox
  #TODO implement dk.rb copy
  FileUtils.cp(File.join(RubyInstaller::ROOT, 'resources', 'devkit', 'devkitvars.cmd'),
              'sandbox/devkit')

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
