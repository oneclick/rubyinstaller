require 'rake'
require 'rake/clean'

namespace(:dependencies) do
  namespace(:openssl) do
    package = RubyInstaller::OpenSsl
    directory package.target
    CLEAN.include(package.target)
    
    # Put files for the :download task
    package.files.each do |f|
      file_source = "#{package.url}/#{f}"
      file_target = "downloads/#{f}"
      download file_target => file_source
      
      # depend on downloads directory
      file file_target => "downloads"
      
      # download task need these files as pre-requisites
      task :download => file_target
    end

    # Prepare the :sandbox, it requires the :download task
    task :extract => [:extract_utils, :download, package.target] do
      # grab the files from the download task
      files = Rake::Task['dependencies:openssl:download'].prerequisites

      files.each { |f|
        extract(File.join(RubyInstaller::ROOT, f), package.target)
      }
    end
    
    configure = "#{package.target}/Configure"
    makefile = "#{package.target}/Makefile"
    libcrypto_a = "#{package.target}/libcrypto.a"
    libssl_a = "#{package.target}/libssl.a"
    libcrypto_dll_a = "#{package.target}/libcrypto.dll.a"
    libssl_dll_a = "#{package.target}/libssl.dll.a"
    
    # Prepare sources for compilation
    task :prepare => ['dependencies:openssl:extract', :compiler, :zlib] do
      patches = Dir.glob("#{package.patches}/*.patch").sort
      patches.each do |patch|
        msys_sh "patch -p1 -d #{package.target} < #{patch}"
      end
      cd File.join(package.target, 'test') do
        ['jpaketest.c', 'mdc2test.c', 'rc5test.c'].each do |file|
          cp 'dummytest.c', file
        end
      end
      touch configure # ensure configure as the first step
    end
    
    file configure => ['dependencies:openssl:prepare']
    file makefile => [configure] do
      cd package.target do
        msys_sh "TERM=msys perl Configure mingw --prefix=/mingw zlib-dynamic"
      end
    end
    
    task :compile_libs => [makefile] do
      cd package.target do
        msys_sh "make build_libs"
      end
    end
    file libcrypto_a => ['dependencies:openssl:compile_libs']
    file libssl_a => ['dependencies:openssl:compile_libs']
    
    if package.shared
      file libcrypto_dll_a => [libcrypto_a] do
        cd package.target do
          msys_sh "perl util/mkdef.pl 32 libeay >libeay32.def"
          msys_sh "dllwrap --dllname #{package.dllnames[:libcrypto]} --output-lib libcrypto.dll.a --def libeay32.def libcrypto.a -lwsock32 -lgdi32"
        end
      end
      
      file libssl_dll_a => [libssl_a] do
        cd package.target do
          msys_sh "perl util/mkdef.pl 32 ssleay >ssleay32.def"
          msys_sh "dllwrap --dllname #{package.dllnames[:libssl]} --output-lib libssl.dll.a --def ssleay32.def libssl.a libcrypto.dll.a"
        end
      end
      
      task :compile => [libcrypto_dll_a, libssl_dll_a]
    else
      task :compile => [libcrypto_a, libssl_a]
    end
    
    task :compile do
      cd package.target do
        msys_sh "make"
      end
    end
    
    task :test => [:compile] do
      cd package.target do
        msys_sh "make test"
      end
    end
    
    task :install => [:compile] do
      target = File.join(RubyInstaller::ROOT, RubyInstaller::MinGW.target)
      cd package.target do
        msys_sh "make install_sw"
        if package.shared
          # these are not handled by make install
          mkdir_p "#{target}/bin"
          cp package.dllnames[:libcrypto], "#{target}/bin"
          cp package.dllnames[:libssl], "#{target}/bin"
          mkdir_p "#{target}/lib"
          cp "libcrypto.dll.a", "#{target}/lib"
          cp "libssl.dll.a", "#{target}/lib"
        end
      end
    end
  end
end

task :openssl => [
  'dependencies:openssl:download',
  'dependencies:openssl:extract',
  'dependencies:openssl:prepare',
  'dependencies:openssl:compile',
  'dependencies:openssl:install'
]

task :dependencies => [:openssl]
