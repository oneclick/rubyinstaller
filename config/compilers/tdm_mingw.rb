module DevKitInstaller

  COMPILERS['tdm-32-4.5.2'] =
    OpenStruct.new(
      :version => 'tdm-32-4.5.2',
      :programs => [ :gcc, :cpp, :'g++' ],
      :program_prefix => nil,
      :url_1 => 'http://downloads.sourceforge.net/tdm-gcc',
      :url_2 => 'http://downloads.sourceforge.net/mingw',
      :target => 'sandbox/devkit/mingw',
      :files => {
        :url_1 => [
          'gcc-4.5.2-tdm-1-core.tar.lzma',
          'gcc-4.5.2-tdm-1-c++.tar.lzma',
        ],
        :url_2 => [
          'binutils-2.21.1-2-mingw32-bin.tar.lzma',
          'mingwrt-3.18-mingw32-dev.tar.gz',
          'mingwrt-3.18-mingw32-dll.tar.gz',
          'w32api-3.17-2-mingw32-dev.tar.lzma',
          'autoconf2.1-2.13-4-mingw32-bin.tar.lzma',
          'autoconf2.5-2.67-1-mingw32-bin.tar.lzma',
          'autoconf-9-1-mingw32-bin.tar.lzma',
          'automake1.11-1.11.1-1-mingw32-bin.tar.lzma',
          'automake-4-1-mingw32-bin.tar.lzma',
          'gdb-7.3-1-mingw32-bin.tar.lzma',
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

  COMPILERS['tdm-32-4.5.1'] =
    OpenStruct.new(
      :version => 'tdm-32-4.5.1',
      :programs => [ :gcc, :cpp, :'g++' ],
      :program_prefix => nil,
      :url_1 => 'http://downloads.sourceforge.net/tdm-gcc',
      :url_2 => 'http://downloads.sourceforge.net/mingw',
      :target => 'sandbox/devkit/mingw',
      :files => {
        :url_1 => [
          'gcc-4.5.1-tdm-1-core.tar.lzma',
          'gcc-4.5.1-tdm-1-c++.tar.lzma',
        ],
        :url_2 => [
          'binutils-2.21-3-mingw32-bin.tar.lzma',
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

  COMPILERS['tdm-32-4.5.0'] =
    OpenStruct.new(
      :version => 'tdm-32-4.5.0',
      :programs => [ :gcc, :cpp, :'g++' ],
      :program_prefix => nil,
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
          'automake1.11-1.11.1-1-mingw32-bin.tar.lzma',
          'automake-4-1-mingw32-bin.tar.lzma',
          'gdb-7.1-2-mingw32-bin.tar.gz',
          'libexpat-2.0.1-1-mingw32-dll-1.tar.gz',
          'libtool-2.4-1-mingw32-bin.tar.lzma'
        ],
      }
    )

  COMPILERS['tdm-64-4.5.1'] =
    OpenStruct.new(
      :version => 'tdm-64-4.5.1',
      :programs => [ :gcc, :cpp, :'g++' ],
      :program_prefix => nil,
      :url_1 => 'http://downloads.sourceforge.net/tdm-gcc',
      :url_2 => 'http://downloads.sourceforge.net/mingw',
      :target => 'sandbox/devkit/mingw',
      :files => {
        :url_1 => [
          'gcc-4.5.1-tdm64-1-core-2.tar.lzma',
          'binutils-2.20.51-tdm64-20100816.tar.lzma',
          'mingw64-runtime-tdm64-gcc45-svn3485.tar.lzma',
          'gcc-4.5.1-tdm64-1-c++.tar.lzma',
          'gdb-7.1-tdm64-1.tar.lzma'
        ],
        :url_2 => [
          'autoconf2.1-2.13-4-mingw32-bin.tar.lzma',
          'autoconf2.5-2.67-1-mingw32-bin.tar.lzma',
          'autoconf-9-1-mingw32-bin.tar.lzma',
          'automake1.11-1.11.1-1-mingw32-bin.tar.lzma',
          'automake-4-1-mingw32-bin.tar.lzma',
          'libtool-2.4-1-mingw32-bin.tar.lzma'
        ],
      }
    )

end
