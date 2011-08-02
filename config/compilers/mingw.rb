module DevKitInstaller

  COMPILERS['mingw-32-4.5.2'] =
    OpenStruct.new(
      :version => 'mingw-32-4.5.2',
      :programs => [ :gcc, :cpp, :'g++' ],
      :program_prefix => nil,
      :url_1 => 'http://downloads.sourceforge.net/mingw',
      :target => 'sandbox/devkit/mingw',
      :files => {
        :url_1 => [
          'gcc-core-4.5.2-1-mingw32-bin.tar.lzma',
          'gcc-c++-4.5.2-1-mingw32-bin.tar.lzma',
          'libgmp-5.0.1-1-mingw32-dll-10.tar.lzma',
          'libmpc-0.8.1-1-mingw32-dll-2.tar.lzma',
          'libmpfr-2.4.1-1-mingw32-dll-1.tar.lzma',
          'libssp-4.5.2-1-mingw32-dll-0.tar.lzma',
          'binutils-2.21.1-2-mingw32-bin.tar.lzma',
          'mingwrt-3.18-mingw32-dev.tar.gz',
          'mingwrt-3.18-mingw32-dll.tar.gz',
          'w32api-3.17-2-mingw32-dev.tar.lzma',
          'autoconf2.1-2.13-4-mingw32-bin.tar.lzma',
          'autoconf2.5-2.67-1-mingw32-bin.tar.lzma',
          'autoconf-9-1-mingw32-bin.tar.lzma',
          'automake1.11-1.11.1-1-mingw32-bin.tar.lzma',
          'automake-4-1-mingw32-bin.tar.lzma',
          'gdb-7.2-1-mingw32-bin.tar.lzma',
          'libexpat-2.0.1-1-mingw32-dll-1.tar.gz',
          'libtool-2.4-1-mingw32-bin.tar.lzma',
          'bsdtar-2.8.3-1-mingw32-bin.tar.bz2',
          'bsdcpio-2.8.3-1-mingw32-bin.tar.bz2',
          'libarchive-2.8.3-1-mingw32-dll-2.tar.bz2',
          'libbz2-1.0.5-2-mingw32-dll-2.tar.gz',
          'liblzma-4.999.9beta_20100401-1-mingw32-dll-1.tar.bz2',
          'libintl-0.17-1-mingw32-dll-8.tar.lzma',
          'libiconv-1.13.1-1-mingw32-dll-2.tar.lzma',
          'libz-1.2.3-1-mingw32-dll-1.tar.gz'
        ],
      }
    )

  COMPILERS['mingw-32-3.4.5'] =
    OpenStruct.new(
      :version => 'mingw-32-3.4.5',
      :programs => [ :gcc, :cpp, :'g++' ],
      :program_prefix => nil,
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
          'autoconf2.5-2.67-1-mingw32-bin.tar.lzma',
          'autoconf-9-1-mingw32-bin.tar.lzma',
          'automake1.11-1.11.1-1-mingw32-bin.tar.lzma',
          'automake-4-1-mingw32-bin.tar.lzma',
          'gdb-6.8-mingw-3.tar.bz2'
        ]
      }
    )

end
