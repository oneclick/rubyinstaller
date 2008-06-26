require 'rake'
require 'rake/clean'


namespace(:msi) do
  
  task :install do
    sh "msiexec /i  pkg\ruby_installer.msi"
  end
  
  task :uninstall =>  do
    sh "msiexec /x  pkg\ruby_installer.msi"
  end

end
