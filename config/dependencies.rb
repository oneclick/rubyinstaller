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

  KNAPSACK_PACKAGES['openssl'] = OpenStruct.new(
    :human_name => "OpenSSL",
    :version => '1.0.0j',
    :url => "http://packages.openknapsack.org/openssl",
    :target => 'sandbox/openssl',
    :files => [
      'openssl-1.0.0j-x86-windows.tar.lzma'
    ]
  )

  KNAPSACK_PACKAGES['ffi'] = OpenStruct.new(
    :human_name => "libffi",
    :version => '3.0.11',
    :url => "http://packages.openknapsack.org/libffi",
    :target => 'sandbox/libffi',
    :files => [
      'libffi-3.0.11-x86-windows.tar.lzma'
    ]
  )

  KNAPSACK_PACKAGES['yaml'] = OpenStruct.new(
    :human_name => "LibYAML",
    :version => '0.1.4',
    :url => "http://packages.openknapsack.org/libyaml",
    :target => 'sandbox/libyaml',
    :files => [
      'libyaml-0.1.4-x86-windows.tar.lzma'
    ]
  )

  KNAPSACK_PACKAGES['iconv'] = OpenStruct.new(
    :human_name => "Iconv",
    :release => 'official',
    :version => "1.14",
    :url => "http://packages.openknapsack.org/libiconv",
    :target => 'sandbox/iconv',
    :files => [
      'libiconv-1.14-x86-windows.tar.lzma'
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
