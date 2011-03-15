module DevKitInstaller

  COMPILERS['llvm-32-2.8'] =
    OpenStruct.new(
      :version => 'llvm-32-2.8',
      :programs => [ :gcc, :cpp, :'g++' ],
      :program_prefix => 'llvm',
      :url_1 => 'http://llvm.org/releases/2.8',
      :url_2 => 'http://downloads.sourceforge.net/mingw',
      :target => 'sandbox/devkit/mingw',
      :files => {
        :url_1 => [
          'llvm-gcc4.2-2.8-x86-mingw32.tar.bz2',
        ],
        :url_2 => [
          'binutils-2.21-3-mingw32-bin.tar.lzma',
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
        ]
      }
    )

end
