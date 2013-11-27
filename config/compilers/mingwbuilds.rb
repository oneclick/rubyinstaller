module DevKitInstaller
  COMMON_MSYS = [
    'autoconf2.1-2.13-4-mingw32-bin.tar.lzma',
    'autoconf2.5-2.68-1-mingw32-bin.tar.lzma',
    'autoconf-10-1-mingw32-bin.tar.lzma',
    'automake1.11-1.11.1-1-mingw32-bin.tar.lzma',
    'automake-4-1-mingw32-bin.tar.lzma',
    'libexpat-2.0.1-1-mingw32-dll-1.tar.gz',
    'libtool-2.4-1-mingw32-bin.tar.lzma',
    'bsdtar-2.8.3-1-mingw32-bin.tar.bz2',
    'bsdcpio-2.8.3-1-mingw32-bin.tar.bz2',
    'libarchive-2.8.3-1-mingw32-dll-2.tar.bz2',
    'libbz2-1.0.5-2-mingw32-dll-2.tar.gz',
    'liblzma-4.999.9beta_20100401-1-mingw32-dll-1.tar.bz2',
    'libz-1.2.3-1-mingw32-dll-1.tar.gz'
  ] unless DevKitInstaller.constants.include?(:COMMON_MSYS)

  COMPILERS['mingwbuilds-32-4.7.3'] =
    OpenStruct.new(
      :version => 'mingwbuilds-32-4.7.3',
      :programs => [ :gcc, :cpp, :'g++' ],
      :program_prefix => nil,
      :url_1 => 'http://downloads.sourceforge.net/mingwbuilds',
      :url_2 => 'http://downloads.sourceforge.net/mingw',
      :url_3 => 'http://downloads.sourceforge.net/gnuwin32',
      :target => 'sandbox/devkit/mingw',
      :relocate => 'sandbox/devkit/mingw/mingw32',
      :files => {
        :url_1 => [
          "x32-4.7.3-release-win32-sjlj-rev1.7z"
        ],
        :url_2 => COMMON_MSYS,
        :url_3 => [
          'which-2.20-bin.zip'
        ],
      }
    )

  COMPILERS['mingwbuilds-64-4.7.3'] =
    OpenStruct.new(
      :version => 'mingwbuilds-64-4.7.3',
      :programs => [ :gcc, :cpp, :'g++' ],
      :program_prefix => nil,
      :url_1 => 'http://downloads.sourceforge.net/mingwbuilds',
      :url_2 => 'http://downloads.sourceforge.net/mingw',
      :url_3 => 'http://downloads.sourceforge.net/gnuwin32',
      :target => 'sandbox/devkit/mingw',
      :relocate => 'sandbox/devkit/mingw/mingw64',
      :files => {
        :url_1 => [
          "x64-4.7.3-release-win32-sjlj-rev1.7z"
        ],
        :url_2 => COMMON_MSYS,
        :url_3 => [
          'which-2.20-bin.zip'
        ],
      }
    )

end
