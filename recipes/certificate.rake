namespace :certificate do
  cert = RubyInstaller::Certificate

  source = "#{cert.url}/#{cert.file}"
  target = "#{RubyInstaller::DOWNLOADS}/#{cert.file}"

  download target => source
  task :download => target
end

task :certificate => ['certificate:download']
task :downloads => [:certificate]
