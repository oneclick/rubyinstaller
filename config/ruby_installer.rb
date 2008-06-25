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
      :checkout => 'http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_8_6',
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
        'libiconv2.dll'
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
      :release => 'official',
      :version => "1.9.2-1",
      :url => "http://easynews.dl.sourceforge.net/gnuwin32",
      :target => RubyInstaller::MinGW.target,
      :files => [
        'libiconv-1.9.2-1-bin.zip',
        'libiconv-1.9.2-1-lib.zip'
      ]
    )
    
    RubyGems = OpenStruct.new(
      :release => 'official',
      :version => '1.2.0',
      :url => 'http://rubyforge.org/frs/download.php/38646',
      :checkout => 'svn://rubyforge.org/var/svn/rubygems/trunk',
      :checkout_target => 'downloads/rubygems',
      :target => 'sandbox/rubygems',
      :install_target => 'sandbox/rubygems_mingw',
      :configure_options => [
        '--no-ri',
        '--no-rdoc'
      ],
      :files => [
        'rubygems-1.2.0.tgz'
      ]
    )
    
    Wix = OpenStruct.new(
      :release => 'stable',
      :version => '2.0.5805.1',
      :url => 'http://easynews.dl.sourceforge.net/wix',
      :target => 'sandbox/wix',
      :package_target => 'sandbox/package',
      :package_file => 'ruby_installer.msi',
      :files => [
        'wix-2.0.5805.0-binaries.zip'
      ]
    )
    
    Paraffin  = OpenStruct.new(
      :release => 'stable',
      :version => '2.0.5805.1',
      :url => 'http://www.wintellect.com/cs/files/folders/4332/download.aspx',
      :target => RubyInstaller::Wix.target,
      :files => [
        'Paraffin-1.03.zip'
      ]
    )
    
    Patches = OpenStruct.new(
    
     :url => 'http://dump.mmediasys.com/installer3',
     :target => 'sandbox/patches',
     :prepare_target => RubyInstaller::Ruby18.target,
     :files => [
        'patches.zip'
      ]
    )
    
  end
end
