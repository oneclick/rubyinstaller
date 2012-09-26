module DevKitInstaller

  COMPILERS['mingw-32-4.6.2'] =
    OpenStruct.new(
      :version => 'mingw-32-4.6.2',
      :programs => [ :gcc, :cpp, :'g++' ],
      :program_prefix => nil,
      :url_1 => 'http://downloads.sourceforge.net/mingw',
      :url_2 => 'http://downloads.sourceforge.net/gnuwin32',
      :target => 'sandbox/devkit/mingw',
      :files => {
        :url_1 => [
          'gcc-core-4.6.2-1-mingw32-bin.tar.lzma',
          'gcc-c++-4.6.2-1-mingw32-bin.tar.lzma',
          'libgmp-5.0.1-1-mingw32-dll-10.tar.lzma',
          'libmpc-0.8.1-1-mingw32-dll-2.tar.lzma',
          'libmpfr-2.4.1-1-mingw32-dll-1.tar.lzma',
          'libssp-4.6.2-1-mingw32-dll-0.tar.lzma',
          'libgcc-4.6.2-1-mingw32-dll-1.tar.lzma',
          'libstdc++-4.6.2-1-mingw32-dll-6.tar.lzma',
          'binutils-2.22-1-mingw32-bin.tar.lzma',
          'mingwrt-3.20-2-mingw32-dev.tar.lzma',
          'mingwrt-3.20-2-mingw32-dll.tar.lzma',
          'w32api-3.17-2-mingw32-dev.tar.lzma',
          'autoconf2.5-2.68-1-mingw32-bin.tar.lzma',
          'autoconf-10-1-mingw32-bin.tar.lzma',
          'automake1.11-1.11.1-1-mingw32-bin.tar.lzma',
          'automake-4-1-mingw32-bin.tar.lzma',
          'gdb-7.5-1-mingw32-bin.tar.lzma',
          'libexpat-2.0.1-1-mingw32-dll-1.tar.gz',
          'libtool-2.4-1-mingw32-bin.tar.lzma',
          'bsdtar-2.8.3-1-mingw32-bin.tar.bz2',
          'bsdcpio-2.8.3-1-mingw32-bin.tar.bz2',
          'libarchive-2.8.3-1-mingw32-dll-2.tar.bz2',
          'libbz2-1.0.5-2-mingw32-dll-2.tar.gz',
          'liblzma-4.999.9beta_20100401-1-mingw32-dll-1.tar.bz2',
          'libintl-0.18.1.1-2-mingw32-dll-8.tar.lzma',
          'libiconv-1.14-2-mingw32-dll-2.tar.lzma',
          'libz-1.2.3-1-mingw32-dll-1.tar.gz'
        ],
        :url_2 => [
          'which-2.20-bin.zip'
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
          'autoconf2.5-2.68-1-mingw32-bin.tar.lzma',
          'autoconf-10-1-mingw32-bin.tar.lzma',
          'automake1.11-1.11.1-1-mingw32-bin.tar.lzma',
          'automake-4-1-mingw32-bin.tar.lzma',
          'gdb-6.8-mingw-3.tar.bz2'
        ]
      }
    )

end
