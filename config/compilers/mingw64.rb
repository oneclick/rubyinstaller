module DevKitInstaller
  COMPILERS['mingw64-32-4.9.0'] =
    OpenStruct.new(
      :version => 'mingw64-32-4.9.0',
      :programs => [ :gcc, :cpp, :'g++' ],
      :program_prefix => nil,
      :url_1 => 'http://downloads.sourceforge.net/mingw-w64',
      :target => 'sandbox/devkit/mingw',
      :relocate => 'sandbox/devkit/mingw/mingw32',
      :files => {
        :url_1 => [
          'i686-4.9.0-release-win32-sjlj-rt_v3-rev2.7z'
        ],
      }
    )

  COMPILERS['mingw64-64-4.9.0'] =
    OpenStruct.new(
      :version => 'mingw64-64-4.9.0',
      :programs => [ :gcc, :cpp, :'g++' ],
      :program_prefix => nil,
      :url_1 => 'http://downloads.sourceforge.net/mingw-w64',
      :target => 'sandbox/devkit/mingw',
      :relocate => 'sandbox/devkit/mingw/mingw64',
      :host => 'x86_64-w64-mingw32',
      :files => {
        :url_1 => [
          'x86_64-4.9.0-release-win32-sjlj-rt_v3-rev2.7z'
        ],
      }
    )

  COMPILERS['mingw64-32-4.8.2'] =
    OpenStruct.new(
      :version => 'mingw64-32-4.8.2',
      :programs => [ :gcc, :cpp, :'g++' ],
      :program_prefix => nil,
      :url_1 => 'http://downloads.sourceforge.net/mingw-w64',
      :target => 'sandbox/devkit/mingw',
      :relocate => 'sandbox/devkit/mingw/mingw32',
      :files => {
        :url_1 => [
          'i686-4.8.2-release-win32-sjlj-rt_v3-rev4.7z'
        ],
      }
    )

  COMPILERS['mingw64-64-4.8.2'] =
    OpenStruct.new(
      :version => 'mingw64-64-4.8.2',
      :programs => [ :gcc, :cpp, :'g++' ],
      :program_prefix => nil,
      :url_1 => 'http://downloads.sourceforge.net/mingw-w64',
      :target => 'sandbox/devkit/mingw',
      :relocate => 'sandbox/devkit/mingw/mingw64',
      :host => 'x86_64-w64-mingw32',
      :files => {
        :url_1 => [
          'x86_64-4.8.2-release-win32-sjlj-rt_v3-rev4.7z'
        ],
      }
    )

  COMPILERS['mingw64-32-4.7.2'] =
    OpenStruct.new(
      :version => 'mingw64-32-4.7.2',
      :programs => [ :gcc, :cpp, :'g++' ],
      :program_prefix => nil,
      :url_1 => 'http://downloads.sourceforge.net/mingw-w64',
      :target => 'sandbox/devkit/mingw',
      :relocate => 'sandbox/devkit/mingw/mingw32',
      :files => {
        :url_1 => [
          'i686-w64-mingw32-gcc-4.7.2-release-win32_rubenvb.7z',
          'i686_64-w64-mingw32-mingw-w64-update-v2.0.7_rubenvb.7z'
        ],
      }
    )

  COMPILERS['mingw64-64-4.7.2'] =
    OpenStruct.new(
      :version => 'mingw64-64-4.7.2',
      :programs => [ :gcc, :cpp, :'g++' ],
      :program_prefix => nil,
      :url_1 => 'http://downloads.sourceforge.net/mingw-w64',
      :target => 'sandbox/devkit/mingw',
      :relocate => 'sandbox/devkit/mingw/mingw64',
      :host => 'x86_64-w64-mingw32',
      :files => {
        :url_1 => [
          'x86_64-w64-mingw32-gcc-4.7.2-release-win64_rubenvb.7z',
          'x86_64-w64-mingw32-mingw-w64-update-v2.0.7_rubenvb.7z'
        ],
      }
    )

end
