require 'ostruct'

module DevKitInstaller
  DEFAULT_VERSION = 'tdm-32-4.5.2'
  COMPILERS = {}
end

# load DevKit compiler definitions
Dir.glob("#{RubyInstaller::ROOT}/config/compilers/*.rb").sort.each do |compiler|
  puts "Loading #{File.basename(compiler)}" if Rake.application.options.trace
  load compiler
end

module DevKitInstaller

  DevKit = OpenStruct.new(
    :installer_guid => '{D25478D4-72AE-40BF-829F-2C8CE49E2EE8}',
    :install_script => 'resources/devkit/dk.rb',
    :install_script_erb => 'resources/devkit/dk.rb.erb',
    :inno_script => 'resources/devkit/devkit.iss',
    :inno_config => 'resources/devkit/dk_config.iss',
    :inno_config_erb => 'resources/devkit/dk_config.iss.erb',
    :setup_scripts => [
      'devkitvars.bat',
      'devkitvars.ps1',
      'dk.rb'
    ]
  )

  MSYS = OpenStruct.new(
    :version => '1.0.17',
    :url_1 => 'http://downloads.sourceforge.net/mingw',
    :target => 'sandbox/devkit',
    :files => {
      :url_1 => [
        'msysCORE-1.0.17-1-msys-1.0.17-bin.tar.lzma',
        'msysCORE-1.0.17-1-msys-1.0.17-ext.tar.lzma',
        'coreutils-5.97-3-msys-1.0.13-bin.tar.lzma',
        'coreutils-5.97-3-msys-1.0.13-ext.tar.lzma',
        'libiconv-1.14-1-msys-1.0.17-dll-2.tar.lzma',
        'libintl-0.18.1.1-1-msys-1.0.17-dll-8.tar.lzma',
        'libtermcap-0.20050421_1-2-msys-1.0.13-dll-0.tar.lzma',
        'make-3.81-3-msys-1.0.13-bin.tar.lzma',
        'perl-5.8.8-1-msys-1.0.17-bin.tar.lzma',
        'zlib-1.2.3-2-msys-1.0.13-dll.tar.lzma',
        'libgdbm-1.8.3-3-msys-1.0.13-dll-3.tar.lzma',
        'libcrypt-1.1_1-3-msys-1.0.13-dll-0.tar.lzma',
        'bash-3.1.23-1-msys-1.0.18-bin.tar.lzma',
        'mksh-40.0.0c-1-msys-1.0.17-bin.tar.lzma',
        'termcap-0.20050421_1-2-msys-1.0.13-bin.tar.lzma',
        'libregex-1.20090805-2-msys-1.0.13-dll-1.tar.lzma',
        'crypt-1.1_1-3-msys-1.0.13-bin.tar.lzma',
        'm4-1.4.14-1-msys-1.0.13-bin.tar.lzma',
        'bison-2.4.2-1-msys-1.0.13-bin.tar.lzma',
        'flex-2.5.35-2-msys-1.0.13-bin.tar.lzma',
        'findutils-4.4.2-2-msys-1.0.13-bin.tar.lzma',
        'sed-4.2.1-2-msys-1.0.13-bin.tar.lzma',
        'gawk-3.1.7-2-msys-1.0.13-bin.tar.lzma',
        'grep-2.5.4-2-msys-1.0.13-bin.tar.lzma',
        'less-436-2-msys-1.0.13-bin.tar.lzma',
        'diffutils-2.8.7.20071206cvs-3-msys-1.0.13-bin.tar.lzma',
        'texinfo-4.13a-2-msys-1.0.13-bin.tar.lzma',
        'libmagic-5.04-1-msys-1.0.13-dll-1.tar.lzma',
        'file-5.04-1-msys-1.0.13-bin.tar.lzma',
        'mintty-1.0.3-1-msys-1.0.17-bin.tar.lzma'
      ],
    }
  )

end
