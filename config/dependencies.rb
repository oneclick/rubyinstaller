module RubyInstaller
  KNAPSACK_PACKAGES = {}

  KNAPSACK_PACKAGES['zlib'] = OpenStruct.new(
    :human_name => "Zlib",
    :release => "alternate",
    :version => "1.2.8",
    :url => "http://dl.bintray.com/oneclick/OpenKnapsack",
    :target => 'sandbox/zlib',
    :files => [
      'zlib-1.2.8-x86-windows.tar.lzma'
    ],
    :x64_files => [
      'zlib-1.2.8-x64-windows.tar.lzma'
    ]
  )

  KNAPSACK_PACKAGES['openssl'] = OpenStruct.new(
    :human_name => "OpenSSL",
    :version => '1.0.1l',
    :url => "http://dl.bintray.com/oneclick/OpenKnapsack",
    :target => 'sandbox/openssl',
    :files => [
      'openssl-1.0.1l-x86-windows.tar.lzma'
    ],
    :x64_files => [
      'openssl-1.0.1l-x64-windows.tar.lzma'
    ]
  )

  KNAPSACK_PACKAGES['ffi'] = OpenStruct.new(
    :human_name => "libffi",
    :version => '3.0.11',
    :url => "http://dl.bintray.com/oneclick/OpenKnapsack",
    :target => 'sandbox/libffi',
    :files => [
      'libffi-3.0.11-x86-windows.tar.lzma'
    ],
    :x64_files => [
      'libffi-3.0.11-x64-windows.tar.lzma'
    ]
  )

  KNAPSACK_PACKAGES['yaml'] = OpenStruct.new(
    :human_name => "LibYAML",
    :version => '0.1.6',
    :url => "http://dl.bintray.com/oneclick/OpenKnapsack",
    :target => 'sandbox/libyaml',
    :files => [
      'libyaml-0.1.6-x86-windows.tar.lzma'
    ],
    :x64_files => [
      'libyaml-0.1.6-x64-windows.tar.lzma'
    ]
  )

  KNAPSACK_PACKAGES['iconv'] = OpenStruct.new(
    :human_name => "Iconv",
    :version => "1.14",
    :url => "http://dl.bintray.com/oneclick/OpenKnapsack",
    :target => 'sandbox/iconv',
    :files => [
      'libiconv-1.14-x86-windows.tar.lzma'
    ],
    :x64_files => [
      'libiconv-1.14-x64-windows.tar.lzma'
    ]
  )

  KNAPSACK_PACKAGES["gdbm"] = OpenStruct.new(
    :human_name => "GDBM",
    :version => "1.8.3",
    :url => "http://dl.bintray.com/oneclick/OpenKnapsack",
    :target => "sandbox/gdbm",
    :files => [
      "gdbm-1.8.3-x86-windows.tar.lzma"
    ],
    :x64_files => [
      "gdbm-1.8.3-x64-windows.tar.lzma"
    ]
  )

  KNAPSACK_PACKAGES["pdcurses"] = OpenStruct.new(
    :human_name => "PDCurses",
    :version => "3.4",
    :url => "http://dl.bintray.com/oneclick/OpenKnapsack",
    :target => "sandbox/pdcurses",
    :files => [
      "pdcurses-3.4-x86-windows.tar.lzma"
    ],
    :x64_files => [
      "pdcurses-3.4-x64-windows.tar.lzma"
    ]
  )

  KNAPSACK_PACKAGES["tcl"] = OpenStruct.new(
    :human_name => "Tcl",
    :version => "8.5.12",
    :url => "http://dl.bintray.com/oneclick/OpenKnapsack",
    :target => "sandbox/tcl",
    :files => [
      "tcl-8.5.12-x86-windows.tar.lzma"
    ],
    :x64_files => [
      "tcl-8.5.12-x64-windows.tar.lzma"
    ]
  )

  KNAPSACK_PACKAGES["tk"] = OpenStruct.new(
    :human_name => "Tk",
    :version => "8.5.12",
    :url => "http://dl.bintray.com/oneclick/OpenKnapsack",
    :target => "sandbox/tk",
    :patches => "resources/patches/tk",
    :files => [
      "tk-8.5.12-x86-windows.tar.lzma"
    ],
    :x64_files => [
      "tk-8.5.12-x64-windows.tar.lzma"
    ],
    :dependencies => [
      :tcl
    ]
  )

  PureReadline = OpenStruct.new(
    :release => 'experimental',
    :version => '0.5.2-0.5.0',
    :url => 'https://github.com/ConnorAtherton/rb-readline/archive',
    :target => 'sandbox/rb-readline',
    :files => [
      'v0.5.3.zip'
    ]
  )

  ExtractUtils = OpenStruct.new(
      :url_1 => 'http://downloads.sourceforge.net/sevenzip',
      :url_2 => 'http://downloads.sourceforge.net/mingw',
      :target => 'sandbox/extract_utils',
      :files => {
        :url_1 => [
          '7za920.zip',
          '7z920.msi',
        ],
        :url_2 => [
          'basic-bsdtar-2.8.3-1-mingw32-bin.zip'
        ],
      }
  )
end
