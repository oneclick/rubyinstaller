module DevKitInstaller

  COMPILERS[:'mingw64-32-4.4.5'] =
    OpenStruct.new(
      :version => :'mingw64-32-4.4.5',
      :programs => [ :gcc, :'g++' ],
      :program_prefix => 'i686-w64-mingw32',
      :url_1 => '',
      :url_2 => '',
      :target => 'sandbox/devkit/mingw',
      :files => {
        :url_1 => [
          '',
        ],
        :url_2 => [
          '',
        ],
      }
    )

  COMPILERS[:'mingw64-64-4.4.5'] =
    OpenStruct.new(
      :version => :'mingw64-64-4.4.5',
      :programs => [ :gcc, :'g++' ],
      :program_prefix => 'x86_64-w64-mingw32',
      :url_1 => '',
      :url_2 => '',
      :target => 'sandbox/devkit/mingw',
      :files => {
        :url_1 => [
          '',
        ],
        :url_2 => [
          '',
        ],
      }
    )

end
