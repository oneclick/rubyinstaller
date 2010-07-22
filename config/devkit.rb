require 'ostruct'

module DevKitInstaller
  DevKit = OpenStruct.new(
    :installer_guid => '{D25478D4-72AE-40BF-829F-2C8CE49E2EE8}',
    :setup_scripts => [
      'devkitvars.bat',
      'dk.rb'
    ]
  )

  MinGWs = [] << OpenStruct.new(
    :version => '4.5.0',
    :url_1 => 'http://downloads.sourceforge.net/tdm-gcc',
    :url_2 => 'http://downloads.sourceforge.net/mingw',
    :target => 'sandbox/devkit/mingw',
    :files => {
      :url_1 => [
        'gcc-4.5.0-tdm-1-core.tar.lzma',
        'gcc-4.5.0-tdm-1-c++.tar.lzma',
      ],
      :url_2 => [
        'binutils-2.20.51-1-mingw32-bin.tar.lzma',
        'mingwrt-3.18-mingw32-dev.tar.gz',
        'mingwrt-3.18-mingw32-dll.tar.gz',
        'w32api-3.14-mingw32-dev.tar.gz',
        'autoconf2.1-2.13-4-mingw32-bin.tar.lzma',
        'autoconf2.5-2.64-1-mingw32-bin.tar.lzma',
        'autoconf-7-1-mingw32-bin.tar.lzma',
        'gdb-7.1-2-mingw32-bin.tar.gz',
        'libexpat-2.0.1-1-mingw32-dll-1.tar.gz'
      ],
    }
  )

  MinGWs << OpenStruct.new(
    :version => '3.4.5',
    :url_1 => 'http://downloads.sourceforge.net/mingw',
    :target => 'sandbox/devkit/mingw',
    :files => {
      :url_1 => [
        'mingwrt-3.15.2-mingw32-dll.tar.gz',
        'mingwrt-3.15.2-mingw32-dev.tar.gz',
        'w32api-3.13-mingw32-dev.tar.gz',
        'binutils-2.19.1-mingw32-bin.tar.gz',
        'gcc-core-3.4.5-20060117-3.tar.gz',
        'gcc-g++-3.4.5-20060117-3.tar.gz',
        'autoconf2.1-2.13-4-mingw32-bin.tar.lzma',
        'autoconf2.5-2.64-1-mingw32-bin.tar.lzma',
        'autoconf-7-1-mingw32-bin.tar.lzma',
        'gdb-6.8-mingw-3.tar.bz2'
      ]
    }
  )

  MSYS = OpenStruct.new(
    :version => '1.0.15',
    :url_1 => 'http://downloads.sourceforge.net/mingw',
    :target => 'sandbox/devkit',
    :files => {
      :url_1 => [
        'msysCORE-1.0.15-1-msys-1.0.15-bin.tar.lzma',
        'msysCORE-1.0.15-1-msys-1.0.15-ext.tar.lzma',
        'coreutils-5.97-3-msys-1.0.13-bin.tar.lzma',
        'coreutils-5.97-3-msys-1.0.13-ext.tar.lzma',
        'libiconv-1.13.1-2-msys-1.0.13-dll-2.tar.lzma',
        'libintl-0.17-2-msys-dll-8.tar.lzma',
        'libtermcap-0.20050421_1-2-msys-1.0.13-dll-0.tar.lzma',
        'make-3.81-3-msys-1.0.13-bin.tar.lzma',
        'perl-5.6.1_2-2-msys-1.0.13-bin.tar.lzma',
        'zlib-1.2.3-2-msys-1.0.13-dll.tar.lzma',
        'libgdbm-1.8.3-3-msys-1.0.13-dll-3.tar.lzma',
        'libcrypt-1.1_1-3-msys-1.0.13-dll-0.tar.lzma',
        'bash-3.1.17-3-msys-1.0.13-bin.tar.lzma',
        'termcap-0.20050421_1-2-msys-1.0.13-bin.tar.lzma',
        'libregex-1.20090805-2-msys-1.0.13-dll-1.tar.lzma',
        'crypt-1.1_1-3-msys-1.0.13-bin.tar.lzma',
        'm4-1.4.14-1-msys-1.0.13-bin.tar.lzma',
        'bison-2.4.2-1-msys-1.0.13-bin.tar.lzma',
        'flex-2.5.35-2-msys-1.0.13-bin.tar.lzma',
        'findutils-4.4.2-2-msys-1.0.13-bin.tar.lzma',
        'sed-4.2.1-2-msys-1.0.13-bin.tar.lzma',
        'gawk-3.1.7-2-msys-1.0.13-bin.tar.lzma',
        'grep-2.5.4-2-msys-1.0.13-bin.tar.lzma'
      ],
    }
  )
end
