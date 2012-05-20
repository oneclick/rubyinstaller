require 'ostruct'

module RubyInstaller
  unless defined?(ROOT)
    # Root folder
    ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))

    # Console based utilities
    SEVEN_ZIP = File.expand_path(File.join(ROOT, 'sandbox', 'extract_utils', '7za.exe'))
    BSD_TAR = File.expand_path(File.join(ROOT, 'sandbox', 'extract_utils', 'basic-bsdtar.exe'))

    # SSL Certificates
    Certificate = OpenStruct.new(
      :url  => 'http://curl.haxx.se/ca',
      :file => 'cacert.pem'
    )

    Ruby18 = OpenStruct.new(
      :version => '1.8.7-p358',
      :short_version => 'ruby18',
      :url => "http://ftp.ruby-lang.org/pub/ruby/1.8",
      :checkout => 'http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_8_7',
      :checkout_target => 'downloads/ruby_1_8',
      :target => 'sandbox/ruby_1_8',
      :doc_target => 'sandbox/doc/ruby18',
      :build_target => 'sandbox/ruby18_build',
      :install_target => 'sandbox/ruby18_mingw',
      :patches => 'resources/patches/ruby187',
      :configure_options => [
        '--enable-shared',
        '--with-winsock2',
        '--disable-install-doc',
        "CFLAGS='-g -O2 -DFD_SETSIZE=256'"
      ],
      :files => [
        'ruby-1.8.7-p358.tar.bz2'
      ],
      :dependencies => [
        :gdbm, :iconv, :openssl, :pdcurses, :zlib, :tcl, :tk
      ],
      :excludes => [
        'libcharset1.dll'
      ],
      :installer_guid => '{F6377277-9DF1-4a1f-A487-CB5D34DCD793}'
    )

    # switch to Ruby 1.8.6 for "1.8" branch at runtime
    if ENV['COMPAT'] then
      Ruby18.version = '1.8.6-p398'
      Ruby18.checkout = 'http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_8_6'
      Ruby18.files = ['ruby-1.8.6-p398.tar.bz2']
      Ruby18.patches = nil
      Ruby18.installer_guid = '{CE65B110-8786-47EA-A4A0-05742F29C221}'
    end

    Ruby19 = OpenStruct.new(
      :version => "1.9.3-p194",
      :short_version => 'ruby19',
      :url => "http://ftp.ruby-lang.org/pub/ruby/1.9",
      :checkout => 'http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_9_3',
      :checkout_target => 'downloads/ruby_1_9',
      :target => 'sandbox/ruby_1_9',
      :doc_target => 'sandbox/doc/ruby19',
      :build_target => 'sandbox/ruby19_build',
      :install_target => 'sandbox/ruby19_mingw',
      :patches => 'resources/patches/ruby193',
      :configure_options => [
        '--enable-shared',
        '--disable-install-doc',
        'debugflags=-g',
        "CPPFLAGS='-DFD_SETSIZE=32767'"
      ],
      :files => [
        'ruby-1.9.3-p194.tar.bz2'
      ],
      :dependencies => [
        :ffi, :gdbm, :iconv, :openssl, :pdcurses, :yaml, :zlib, :tcl, :tk
      ],
      :excludes => [
        'libcharset1.dll'
      ],
      :installer_guid => '{17E73B15-62D2-43FD-B851-ACF86A8C9D25}'
    )

    # COMPAT mode for Ruby 1.9.2
    if ENV['COMPAT'] then
      Ruby19.version = "1.9.2-p290"
      Ruby19.checkout = 'http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_9_2'
      Ruby19.files = ['ruby-1.9.2-p290.tar.bz2']
      Ruby19.installer_guid = '{BD5F3A9C-22D5-4C1D-AEA0-ED1BE83A1E67}'
    end

    # OBSOLETE for Ruby 1.9.1
    if ENV["OBSOLETE"]
      Ruby19.version = '1.9.1-p430'
      Ruby19.checkout = 'http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_9_1'
      Ruby19.files = ['ruby-1.9.1-p430.tar.bz2']
      Ruby19.dependencies = [:gdbm, :iconv, :openssl, :pdcurses, :zlib]
      Ruby19.patches = nil
      Ruby19.installer_guid = '{11233A17-BFFC-434A-8FC8-2E93369AF008}'
    end

    # Modify relevent configuration metadata when building from a
    # local repository
    if ENV['LOCAL'] then
      Ruby18.installer_guid = '{12E6FD2D-D425-4E32-B77B-020A15A8346F}'
      Ruby18.target = ENV['LOCAL'].gsub('\\', File::SEPARATOR)

      Ruby19.patches = nil
      Ruby19.target = ENV['LOCAL'].gsub('\\', File::SEPARATOR)
      Ruby19.installer_guid = '{17E73B15-62D2-43FD-B851-ACF86A8C9D25}'
    end

    # alter at runtime the checkout and versions of 1.9
    if ENV['TRUNK'] then
      Ruby19.version = '2.0.0'
      Ruby19.checkout = 'http://svn.ruby-lang.org/repos/ruby/trunk'
      Ruby19.installer_guid = "{270FF09A-DC07-499D-B5D7-C4F5A30EDC83}"
    end

    # do not build or prepare any dependency library
    if ENV['NODEPS'] then
      Ruby18.dependencies.clear
      Ruby19.dependencies.clear
    end

    # do not build Tk extension or supporting libraries
    if ENV['NOTK'] then
      [:tcl, :tk].each do |pkg|
        Ruby18.dependencies.delete(pkg)
        Ruby19.dependencies.delete(pkg)
      end
    end

    Zlib = OpenStruct.new(
      :release => "alternate",
      :version => "1.2.7",
      :url => "http://packages.openknapsack.org/zlib",
      :target => 'sandbox/zlib',
      :files => [
        'zlib-1.2.7-x86-windows.tar.lzma'
      ]
    )

    PureReadline = OpenStruct.new(
      :release => 'experimental',
      :version => '0.5.2-0.4.2',
      :url => 'http://cloud.github.com/downloads/luislavena/rb-readline',
      :target => 'sandbox/rb-readline',
      :files => [
        'rb-readline-0.4.2.zip'
      ]
    )

    PdCurses = OpenStruct.new(
      :version => '3.4',
      :url => "http://downloads.sourceforge.net/pdcurses",
      :target => 'sandbox/pdcurses',
      :files => [
        'pdc34dll.zip'
      ]
    )

    ExtractUtils = OpenStruct.new(
        :url_1 => 'http://downloads.sourceforge.net/sevenzip',
        :url_2 => 'http://downloads.sourceforge.net/mingw',
        :target => 'sandbox/extract_utils',
        :files => {
          :url_1 => [
            '7za465.zip',
            '7z465.msi',
          ],
          :url_2 => [
            'basic-bsdtar-2.8.3-1-mingw32-bin.zip'
          ],
        }
    )

    OpenSsl = OpenStruct.new(
      :url => 'http://openssl.org/source/',
      :version => '1.0.0j',
      :target => 'sandbox/src-openssl',
      :install_target => 'sandbox/openssl',
      :patches => 'resources/patches/openssl',
      :configure_options => [
        'mingw',
        'zlib-dynamic'
      ],
      :dllnames => {
        :libcrypto => 'libeay32-1.0.0-msvcrt.dll',
        :libssl => 'ssleay32-1.0.0-msvcrt.dll',
      },
      :files => [
        'openssl-1.0.0j.tar.gz',
      ]
    )

    LibYAML = OpenStruct.new(
      :url => 'http://pyyaml.org/download/libyaml',
      :version => '0.1.4',
      :target => 'sandbox/src-libyaml',
      :install_target => 'sandbox/libyaml',
      :patches => 'resources/patches/yaml',
      :configure_options => [
        '--enable-static',
        '--disable-shared'
      ],
      :files => [
        'yaml-0.1.4.tar.gz',
      ]
    )

    LibFFI = OpenStruct.new(
      :url => 'http://github.com/atgreen/libffi/tarball/v3.0.11',
      :version => '3.0.11',
      :target => 'sandbox/src-libffi',
      :install_target => 'sandbox/libffi',
      :patches => 'resources/patches/libffi',
      :configure_options => [
        '--enable-static',
        '--disable-shared'
      ],
      :files => [
        'libffi-3.0.11.tar.gz',
      ]
    )

    Tcl = OpenStruct.new(
      :version => '8.5.11',
      :url => "http://downloads.sourceforge.net/tcl",
      :target => 'sandbox/src-tcl',
      :install_target => 'sandbox/tcl',
      :patches => 'resources/patches/tcl',
      :configure_options => [
        '--enable-threads'
      ],
      :files => [
        'tcl8.5.11-src.tar.gz'
      ]
    )

    Tk = OpenStruct.new(
      :version => '8.5.11',
      :url => "http://downloads.sourceforge.net/tcl",
      :target => 'sandbox/src-tk',
      :install_target => 'sandbox/tk',
      :patches => 'resources/patches/tk',
      :configure_options => [
        '--enable-threads'
      ],
      :files => [
        'tk8.5.11-src.tar.gz'
      ],
      :dependencies => [
        :tcl
      ]
    )

    Iconv = OpenStruct.new(
      :release => 'official',
      :version => "1.9.2-1",
      :url => "http://downloads.sourceforge.net/gnuwin32",
      :target => 'sandbox/iconv',
      :files => [
        'libiconv-1.9.2-1-bin.zip',
        'libiconv-1.9.2-1-lib.zip'
      ]
    )

    Gdbm = OpenStruct.new(
      :release => 'official',
      :version => '1.8.3-1',
      :url => "http://downloads.sourceforge.net/gnuwin32",
      :target => 'sandbox/gdbm',
      :files => [
        'gdbm-1.8.3-1-bin.zip',
        'gdbm-1.8.3-1-lib.zip',
        'gdbm-1.8.3-1-src.zip'
      ]
    )

    RubyGems = OpenStruct.new(
      :release => 'official',
      :version => '1.8.24',
      :url => 'http://rubyforge.org/frs/download.php/76073',
      :checkout => 'http://github.com/rubygems/rubygems.git',
      :checkout_target => 'downloads/rubygems',
      :target => 'sandbox/rubygems',
      :configure_options => [
        '--no-ri',
        '--no-rdoc'
      ],
      :files => [
        'rubygems-1.8.24.tgz'
      ],
      :hooks => [
        'resources/rubygems/operating_system.rb'
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
