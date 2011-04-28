require 'rake'
require 'rake/clean'

namespace(:dependencies) do
  namespace(:openssl) do
    package = RubyInstaller::OpenSsl
    directory package.target
    CLEAN.include(package.target)
    CLEAN.include(package.install_target)

    # Put files for the :download task
    dt = checkpoint(:openssl, :download)
    package.files.each do |f|
      file_source = "#{package.url}/#{f}"
      file_target = "downloads/#{f}"
      download file_target => file_source

      # depend on downloads directory
      file file_target => "downloads"

      # download task need these files as pre-requisites
      dt.enhance [file_target]
    end
    task :download => dt

    # Prepare the :sandbox, it requires the :download task
    et = checkpoint(:openssl, :extract) do
      dt.prerequisites.each { |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target, :noerror => true)
      }
    end
    task :extract => [:extract_utils, :download, package.target, et]

    # Apply patches
    pt = checkpoint(:openssl, :prepare) do
      patches = Dir.glob("#{package.patches}/*.patch").sort
      patches.each do |patch|
        sh "git apply --directory #{package.target} #{patch}"
      end
    end
    task :prepare => [:extract, pt]

    # Prepare sources for compilation
    ct = checkpoint(:openssl, :configure) do
      # set TERM to MSYS to generate symlinks
      old_term = ENV['TERM']
      ENV['TERM'] = 'msys'

      install_target = File.join(RubyInstaller::ROOT, package.install_target)
      cd package.target do
        sh "perl ./Configure #{package.configure_options.join(' ')} --prefix=#{install_target}"
      end

      ENV['TERM'] = old_term
    end
    task :configure => [:prepare, :compiler, :zlib, ct]

    mt = checkpoint(:openssl, :make) do
      cd package.target do
        # ensure dllwrap uses the correct compiler executable as its driver
        compiler = DevKitInstaller::COMPILERS[ENV['DKVER']]
        driver = compiler.program_prefix.nil? ? '': "--driver-name #{compiler.program_prefix}-gcc"

        sh "make"
        sh "perl util/mkdef.pl 32 libeay > libeay32.def"
        sh "dllwrap --dllname #{package.dllnames[:libcrypto]} #{driver} --output-lib libcrypto.dll.a --def libeay32.def libcrypto.a -lcrypt32 -lwsock32 -lgdi32"
        sh "perl util/mkdef.pl 32 ssleay > ssleay32.def"
        sh "dllwrap --dllname #{package.dllnames[:libssl]} #{driver} --output-lib libssl.dll.a --def ssleay32.def libssl.a libcrypto.dll.a"
      end
    end
    task :compile => [:configure, mt]

    it = checkpoint(:openssl, :install) do
      target = File.join(RubyInstaller::ROOT, RubyInstaller::OpenSsl.install_target)
      cd package.target do
        sh "make install_sw"
        # these are not handled by make install
        mkdir_p "#{target}/bin"
        cp package.dllnames[:libcrypto], "#{target}/bin"
        cp package.dllnames[:libssl], "#{target}/bin"
        mkdir_p "#{target}/lib"
        cp "libcrypto.dll.a", "#{target}/lib"
        cp "libssl.dll.a", "#{target}/lib"
      end
    end
    task :install => [:compile, it]

    task :activate => [:compile] do
      puts "Activating OpenSSL version #{package.version}"
      activate(package.install_target)
    end
  end
end

task :openssl => [
  'dependencies:openssl:download',
  'dependencies:openssl:extract',
  'dependencies:openssl:prepare',
  'dependencies:openssl:compile',
  'dependencies:openssl:install',
  'dependencies:openssl:activate'
]
