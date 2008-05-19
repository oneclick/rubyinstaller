require 'ostruct'

module RubyInstaller
  module Version
    unless defined?(MAJOR)
      MAJOR = 3
      MINOR = 0
      REVISION = 0
    end
  end
  
  unless defined?(ROOT)
    # Root folder
    ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))
    
    # MinGW files
    MinGW = OpenStruct.new(
      :release => 'current',
      :version => '3.4.5',
      :url => "http://easynews.dl.sourceforge.net/mingw",
      :target => 'sandbox/mingw',
      :files => [
        'binutils-2.17.50-20060824-1.tar.gz',
        'gcc-core-3.4.5-20060117-3.tar.gz',
        'gcc-g++-3.4.5-20060117-3.tar.gz',
        'mingw-runtime-3.14.tar.gz',
        'mingw-utils-0.3.tar.gz',
        'w32api-3.11.tar.gz',
        'gdb-6.8-mingw-3.tar.bz2'
      ]
    )
    
    MSYS = OpenStruct.new(
      :release => 'technology-preview',
      :version => '1.0.11',
      :url => "http://easynews.dl.sourceforge.net/mingw",
      :target => 'sandbox/msys',
      :files => [
        'diffutils-2.8.7-MSYS-1.0.11-snapshot.tar.bz2',
        'findutils-4.3.0-MSYS-1.0.11-snapshot.tar.bz2',
        'gawk-3.1.5-MSYS-1.0.11-snapshot.tar.bz2',
        'msysCORE-1.0.11-2007.01.19-1.tar.bz2',
        'MSYS-1.0.11-20070729.tar.bz2',
        'coreutils-5.97-MSYS-1.0.11-snapshot.tar.bz2',
        'texinfo-4.11-MSYS-1.0.11.tar.bz2',
        'bash-3.1-MSYS-1.0.11-1.tar.bz2',
        'bison-2.3-MSYS-1.0.11.tar.bz2',
        'perl-5.6.1-MSYS-1.0.11.tar.bz2',
        'm4-1.4.7-MSYS.tar.bz2',
        'msys-autoconf-2.59.tar.bz2',
        'msys-automake-1.8.2.tar.bz2',
        'msys-libtool-1.5.tar.bz2'
      ]
    )
    
    Ruby18 = OpenStruct.new(
      :release => "preview1",
      :version => "1.8.6-p114",
      :url => "http://ftp.ruby-lang.org/pub/ruby/1.8",
      :checkout => 'http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_8',
      :checkout_target => 'downloads/ruby_1_8',
      :target => 'sandbox/ruby_1_8',
      :build_target => 'sandbox/ruby_build',
      :install_target => 'sandbox/ruby_mingw',
      :configure_options => [
        '--enable-shared',
        '--with-winsock2',
        '--disable-install-doc'
      ],
      :files => [
        'ruby-1.8.6-p114.tar.bz2'
      ],
      :dependencies => [
        'readline5.dll',
        'zlib1.dll',
        'libeay32.dll',
        'libssl32.dll',
        'iconv.dll'
      ]
    )
    
    Zlib = OpenStruct.new(
      :release => "official",
      :version => "1.2.3",
      :url => "http://www.zlib.net",
      :target => RubyInstaller::MinGW.target,
      :files => [
        'zlib123-dll.zip'
      ]
    )
    
    # FIXME: using direct mirror for Readline since GnuWin32 seems failing
    # to grab a correct link (stack level too deep due redirections)
    Readline = OpenStruct.new(
      :release => "official",
      :version => "5.0",
      :url => "http://easynews.dl.sourceforge.net/sourceforge/gnuwin32",
      :target => RubyInstaller::MinGW.target,
      :files => [
        'readline-5.0-bin.zip',
        'readline-5.0-lib.zip'
      ]
    )
  
    ExtractUtils = OpenStruct.new(
        :url => "http://easynews.dl.sourceforge.net/sevenzip",
        :target => 'sandbox/extract_utils',
        :files => [
          '7za458.zip'
        ]
    )
    
    OpenSsl = OpenStruct.new(
      :url => "http://easynews.dl.sourceforge.net/gnuwin32",
      :version => '0.9.7.c',
      :target => RubyInstaller::MinGW.target,
      :files => [
        'openssl-0.9.7c-bin.zip',
        'openssl-0.9.7c-lib.zip'
      ]
    )
    
    Iconv = OpenStruct.new(
      :release => 'windows alternative',
      :version => "20080320",
      :url => "http://ftp.gnome.org/pub/gnome/binaries/win32/dependencies",
      :target => RubyInstaller::MinGW.target,
      :files => [
        'win_iconv-tml-20080320.zip',
        'win_iconv_dll-tml-20080320.zip'
      ]
    )
    
    RubyGems = OpenStruct.new(
      :release => 'official',
      :version => '1.1.1',
      :url => 'http://rubyforge.org/frs/download.php/35283',
      :checkout => 'svn://rubyforge.org/var/svn/rubygems/trunk',
      :checkout_target => 'downloads/rubygems',
      :target => 'sandbox/rubygems',
      :install_target => RubyInstaller::Ruby18.install_target,
      :configure_options => [
        '--no-ri',
        '--no-rdoc',
        'RUBYOPT='
      ],
      :files => [
        'rubygems-1.1.1.tgz'
      ]
    )
  end
end
