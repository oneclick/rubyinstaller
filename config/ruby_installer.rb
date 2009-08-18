require 'ostruct'

module RubyInstaller
  module Version
    unless defined?(MAJOR)
      MAJOR = 3
      MINOR = 0
      REVISION = 0
    end

    unless defined?(STRING)
      STRING = [MAJOR, MINOR, REVISION].join('.')
    end
  end

  unless defined?(ROOT)
    # Root folder
    ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))

    # MinGW files
    MinGW = OpenStruct.new(
      :release => 'current',
      :version => '3.4.5',
      :url => "http://downloads.sourceforge.net/mingw",
      :target => 'sandbox/mingw',
      :files => [
        'mingwrt-3.15.2-mingw32-dll.tar.gz',
        'mingwrt-3.15.2-mingw32-dev.tar.gz',
        'w32api-3.13-mingw32-dev.tar.gz',
        'binutils-2.19.1-mingw32-bin.tar.gz',
        'gcc-core-3.4.5-20060117-3.tar.gz',
        'gcc-g++-3.4.5-20060117-3.tar.gz',
        'gdb-6.8-mingw-3.tar.bz2'
      ]
    )

    MSYS = OpenStruct.new(
      :release => 'technology-preview',
      :version => '1.0.11',
      :url => "http://downloads.sourceforge.net/mingw",
      :target => 'sandbox/msys',
      :files => [
        'msysCORE-1.0.11-20080826.tar.gz',
        'findutils-4.3.0-MSYS-1.0.11-3-bin.tar.gz',
        'MSYS-1.0.11-20090120-dll.tar.gz',
        'tar-1.19.90-MSYS-1.0.11-2-bin.tar.gz',
        'autoconf2.5-2.61-1-bin.tar.bz2',
        'autoconf-4-1-bin.tar.bz2',
        'perl-5.6.1-MSYS-1.0.11-1.tar.bz2',
        'crypt-1.1-1-MSYS-1.0.11-1.tar.bz2',
        'bison-2.3-MSYS-1.0.11-1.tar.bz2'
      ]
    )

    Ruby18 = OpenStruct.new(
      :version => "1.8.6-p383",
      :url => "http://ftp.ruby-lang.org/pub/ruby/1.8",
      :checkout => 'http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_8_6',
      :checkout_target => 'downloads/ruby_1_8',
      :target => 'sandbox/ruby_1_8',
      :build_target => 'sandbox/ruby18_build',
      :install_target => 'sandbox/ruby18_mingw',
      :configure_options => [
        '--enable-shared',
        '--with-winsock2',
        '--disable-install-doc'
      ],
      :files => [
        'ruby-1.8.6-p383.tar.bz2'
      ],
      :dependencies => [
        'zlib1.dll',
        'libeay32.dll',
        'libssl32.dll',
        'libiconv2.dll',
        'pdcurses.dll',
        'gdbm3.dll'
      ]
    )

    Ruby19 = OpenStruct.new(
      :version => "1.9.1-p243",
      :url => "http://ftp.ruby-lang.org/pub/ruby/1.9",
      :checkout => 'http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_9_1',
      :checkout_target => 'downloads/ruby_1_9',
      :target => 'sandbox/ruby_1_9',
      :build_target => 'sandbox/ruby19_build',
      :install_target => 'sandbox/ruby19_mingw',
      :configure_options => [
        '--enable-shared',
        '--disable-install-doc'
      ],
      :files => [
        'ruby-1.9.1-p243.tar.bz2'
      ],
      :dependencies => [
        'zlib1.dll',
        'libeay32.dll',
        'libssl32.dll',
        'libiconv2.dll',
        'pdcurses.dll',
        'gdbm3.dll'
      ]
    )

    # alter at runtime the checkout and versions of 1.9
    if ENV['TRUNK'] then
      Ruby19.version = '1.9.2-dev'
      Ruby19.checkout = 'http://svn.ruby-lang.org/repos/ruby/trunk'
    end

    Zlib = OpenStruct.new(
      :release => "official",
      :version => "1.2.3",
      :url => "http://www.zlib.net",
      :target => RubyInstaller::MinGW.target,
      :files => [
        'zlib123-dll.zip'
      ]
    )

    PureReadline = OpenStruct.new(
      :release => 'experimental',
      :version => '0.5.2-0.1.2',
      :url => 'http://cloud.github.com/downloads/luislavena/rb-readline',
      :target => 'sandbox/rb-readline',
      :files => [
        'rb-readline-0.1.2.zip'
      ]
    )

    PdCurses = OpenStruct.new(
      :version => '3.3',
      :url => "http://downloads.sourceforge.net/pdcurses",
      :target => RubyInstaller::MinGW.target,
      :files => [ 
        'pdc33dll.zip' 
      ]
    )

    ExtractUtils = OpenStruct.new(
        :url => "http://downloads.sourceforge.net/sevenzip",
        :target => 'sandbox/extract_utils',
        :files => [
          '7za465.zip'
        ]
    )

    OpenSsl = OpenStruct.new(
      :url => 'http://www.openssl.org/source',
      :version => '0.9.8k',
      :target => 'sandbox/openssl',
      :patches => 'resources/patches/openssl',
      :shared => true,
      :dllnames => {
        :libcrypto => 'libeay32-0.9.8-msvcrt.dll',
        :libssl => 'ssleay32-0.9.8-msvcrt.dll',
      },
      :files => [
        'openssl-0.9.8k.tar.gz',
      ]
    )
    [Ruby18, Ruby19].each do |ruby|
      ruby.dependencies << OpenSsl.dllnames[:libcrypto]
      ruby.dependencies << OpenSsl.dllnames[:libssl]
    end

    Iconv = OpenStruct.new(
      :release => 'official',
      :version => "1.9.2-1",
      :url => "http://downloads.sourceforge.net/gnuwin32",
      :target => RubyInstaller::MinGW.target,
      :files => [
        'libiconv-1.9.2-1-bin.zip',
        'libiconv-1.9.2-1-lib.zip'
      ]
    )

    Gdbm = OpenStruct.new(
      :release => 'official',
      :version => '1.8.3-1',
      :url => "http://downloads.sourceforge.net/gnuwin32",
      :target => RubyInstaller::MinGW.target,
      :files => [
        'gdbm-1.8.3-1-bin.zip',
        'gdbm-1.8.3-1-lib.zip',
        'gdbm-1.8.3-1-src.zip'
      ]
    )

    RubyGems = OpenStruct.new(
      :release => 'official',
      :version => '1.3.5',
      :url => 'http://rubyforge.org/frs/download.php/60718',
      :checkout => 'svn://rubyforge.org/var/svn/rubygems/trunk',
      :checkout_target => 'downloads/rubygems',
      :target => 'sandbox/rubygems',
      :configure_options => [
        '--no-ri',
        '--no-rdoc'
      ],
      :files => [
        'rubygems-1.3.5.tgz'
      ]
    )

    Book = OpenStruct.new(
      :release => 'official',
      :version => '2009-04-18',
      :url => 'http://www.sapphiresteel.com/IMG/zip',
      :target => 'sandbox/book',
      :files => [
        'book-of-ruby.zip'
      ]
    )
  end
end
