namespace :certificate do
  cert = RubyInstaller::Certificate

  source = "#{cert.url}/#{cert.file}"
  target = "downloads/#{cert.file}"

  download target => source
  task :download => target
end

task :certificate => ['certificate:download']
task :downloads => [:certificate]
