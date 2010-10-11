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
          'binutils-2.20.51-1-mingw32-bin.tar.lzma',
          'autoconf2.1-2.13-4-mingw32-bin.tar.lzma',
          'autoconf2.5-2.67-1-mingw32-bin.tar.lzma',
          'autoconf-9-1-mingw32-bin.tar.lzma',
          'gdb-7.2-1-mingw32-bin.tar.lzma',
          'libexpat-2.0.1-1-mingw32-dll-1.tar.gz'
        ]
      }
    )

end
