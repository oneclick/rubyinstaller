module RubyInstaller
  KNAPSACK_PACKAGES = {}

  KNAPSACK_PACKAGES['zlib'] = OpenStruct.new(
    :human_name => "Zlib",
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
end
