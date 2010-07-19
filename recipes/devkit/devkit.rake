desc 'build DevKit installer and 7z archive.'
task :devkit => ['devkit:msys', 'devkit:mingw'] do
  sevenz_archive = ENV['7Z'] ? true : false

  # copy helper scripts to DevKit sandbox
  #TODO implement dk.rb copy
  FileUtils.cp(File.join(RubyInstaller::ROOT, 'resources', 'devkit', 'devkitvars.cmd'),
              'sandbox/devkit')

  if sevenz_archive
    #TODO strip leading paths from archived files
    #seven_zip_build('sandbox/devkit/*', 'devkit.7z')
  end
end
