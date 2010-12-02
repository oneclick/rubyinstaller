module DevKitInstaller

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
          'autoconf2.5-2.64-1-mingw32-bin.tar.lzma',
          'autoconf-7-1-mingw32-bin.tar.lzma',
          'gdb-6.8-mingw-3.tar.bz2'
        ]
      }
    )

end
