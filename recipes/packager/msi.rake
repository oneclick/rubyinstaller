require 'rake'
require 'rake/clean'


namespace(:msi) do

  desc "install the product"
  task :install do
    sh "msiexec /i  pkg\\ruby_installer.msi"
  end
  
  desc "uninstall the product"
  task :uninstall do
    sh "msiexec /x  pkg\\ruby_installer.msi"
  end
  
  desc "run the installer without installing the product"
  task :test_run do
    sh "msiexec /i  pkg\\ruby_installer.msi EXECUTEMODE=None"
  end

end
