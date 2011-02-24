require 'rake'
require 'rake/clean'

namespace(:interpreter) do
  namespace(:shoes) do
    package = RubyInstaller::Shoes
    
    task :checkout do
      if File.exist?(File.join(RubyInstaller::ROOT, package.checkout_target, ".git"))
        puts "Shoes directory already exists."
      else
	cd RubyInstaller::ROOT do
	  sh "git clone #{package.checkout} #{package.checkout_target}"
	end
      end
    end
    
    task :compile do
      cd File.join(RubyInstaller::ROOT, package.target) do
        sh "rake"
      end
    end
  end
end

task :shoes => [
  "libungif",
  "libjpeg",
  "winhttp",
  "glib",
  "cairo",
  "pango",
  "git",
  "ruby19",
  "port_audio",
  "sqlite",
  "interpreter:shoes:checkout",
  "interpreter:shoes:compile"
  ]
