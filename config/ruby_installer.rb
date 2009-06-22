require 'ostruct'

module RubyInstaller
  module Version
    unless defined?(MAJOR)
      MAJOR = 3
      MINOR = 0
      REVISION = 0
    end

    unless defined?(STRING)
      STRING = [MAJOR, MINOR, REVISION].join('.')
    end
  end

  unless defined?(ROOT)
    # Root folder
    ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))

    # MinGW files
    MinGW = OpenStruct.new(
      :release => 'current',
      :version => '3.4.5',
      :url => "http://downloads.sourceforge.net/mingw",
      :target => 'sandbox/mingw',
      :files => [
        'mingwrt-3.15.2-mingw32-dll.tar.gz',
        'mingwrt-3.15.2-mingw32-dev.tar.gz',
        'w32api-3.13-mingw32-dev.tar.gz',
        'binutils-2.19.1-mingw32-bin.tar.gz',
        'gcc-core-3.4.5-20060117-3.tar.gz',
        'gcc-g++-3.4.5-20060117-3.tar.gz',
        'gdb-6.8-mingw-3.tar.bz2'
      ]
    )

    MSYS = OpenStruct.new(
      :release => 'technology-preview',
      :version => '1.0.11',
      :url => "http://downloads.sourceforge.net/mingw",
      :target => 'sandbox/msys',
      :files => [
        'msysCORE-1.0.11-20080826.tar.gz',
        'findutils-4.3.0-MSYS-1.0.11-3-bin.tar.gz',
        'MSYS-1.0.11-20090120-dll.tar.gz',
        'tar-1.19.90-MSYS-1.0.11-2-bin.tar.gz',
        'autoconf2.5-2.61-1-bin.tar.bz2',
        'autoconf-4-1-bin.tar.bz2',
        'perl-5.6.1-MSYS-1.0.11-1.tar.bz2',
        'crypt-1.1-1-MSYS-1.0.11-1.tar.bz2',
        'bison-2.3-MSYS-1.0.11-1.tar.bz2'
      ]
    )

    Ruby18 = OpenStruct.new(
      :release => "preview1",
      :version => "1.8.6-p368",
      :url => "http://ftp.ruby-lang.org/pub/ruby/1.8",
      :checkout => 'http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_8_6',
      :checkout_target => 'downloads/ruby_1_8',
      :target => 'sandbox/ruby_1_8',
      :build_target => 'sandbox/ruby18_build',
      :install_target => 'sandbox/ruby18_mingw',
      :configure_options => [
        '--enable-shared',
        '--with-winsock2',
        '--disable-install-doc'
      ],
      :files => [
        'ruby-1.8.6-p368.tar.bz2'
      ],
      :dependencies => [
        'readline5.dll',
        'zlib1.dll',
        'libeay32.dll',
        'libssl32.dll',
        'libiconv2.dll',
        'pdcurses.dll',
        'gdbm3.dll'
      ]
    )

    Ruby19 = OpenStruct.new(
      :release => "stable",
      :version => "1.9.1-p129",
      :url => "http://ftp.ruby-lang.org/pub/ruby/1.9",
      :checkout => 'http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_9_1',
      :checkout_target => 'downloads/ruby_1_9',
      :target => 'sandbox/ruby_1_9',
      :build_target => 'sandbox/ruby19_build',
      :install_target => 'sandbox/ruby19_mingw',
      :configure_options => [
        '--enable-shared',
        '--with-winsock2',
        '--disable-install-doc'
      ],
      :files => [
        'ruby-1.9.1-p129.tar.bz2'
      ],
      :dependencies => [
        #'readline5.dll',
        'zlib1.dll',
        'libeay32.dll',
        'libssl32.dll',
        'libiconv2.dll',
        'pdcurses.dll',
        'gdbm3.dll'
      ]
    )

    # alter at runtime the checkout and versions of 1.9
    if ENV['TRUNK'] then
      Ruby19.version = '1.9.2-dev'
      Ruby19.checkout = 'http://svn.ruby-lang.org/repos/ruby/trunk'
    end

    Zlib = OpenStruct.new(
      :release => "official",
      :version => "1.2.3",
      :url => "http://www.zlib.net",
      :target => RubyInstaller::MinGW.target,
      :files => [
        'zlib123-dll.zip'
      ]
    )
    
    # FIXME: using direct mirror for Readline since GnuWin32 seems failing
    # to grab a correct link (stack level too deep due redirections)
    Readline = OpenStruct.new(
      :release => "official",
      :version => "5.0",
      :url => "http://downloads.sourceforge.net/sourceforge/gnuwin32",
      :target => RubyInstaller::MinGW.target,
      :files => [
        'readline-5.0-bin.zip',
        'readline-5.0-lib.zip'
      ]
    )

    PureReadline = OpenStruct.new(
      :release => 'experimental',
      :version => '0.5.2-0.1.2',
      :url => 'http://cloud.github.com/downloads/luislavena/rb-readline',
      :target => 'sandbox/rb-readline',
      :files => [
        'rb-readline-0.1.2.zip'
      ]
    )

    PdCurses = OpenStruct.new(
      :version => '3.3',
      :url => "http://downloads.sourceforge.net/pdcurses",
      :target => RubyInstaller::MinGW.target,
      :files => [ 
        'pdc33dll.zip' 
      ]
    )

    ExtractUtils = OpenStruct.new(
        :url => "http://downloads.sourceforge.net/sevenzip",
        :target => 'sandbox/extract_utils',
        :files => [
          '7za465.zip'
        ]
    )

    OpenSsl = OpenStruct.new(
      :url => "http://downloads.sourceforge.net/gnuwin32",
      :version => '0.9.8h-1',
      :target => RubyInstaller::MinGW.target,
      :files => [
        'openssl-0.9.8h-1-bin.zip',
        'openssl-0.9.8h-1-lib.zip'
      ]
    )

    Iconv = OpenStruct.new(
      :release => 'official',
      :version => "1.9.2-1",
      :url => "http://downloads.sourceforge.net/gnuwin32",
      :target => RubyInstaller::MinGW.target,
      :files => [
        'libiconv-1.9.2-1-bin.zip',
        'libiconv-1.9.2-1-lib.zip'
      ]
    )

    Gdbm = OpenStruct.new(
      :release => 'official',
      :version => '1.8.3-1',
      :url => "http://downloads.sourceforge.net/gnuwin32",
      :target => RubyInstaller::MinGW.target,
      :files => [
        'gdbm-1.8.3-1-bin.zip',
        'gdbm-1.8.3-1-lib.zip',
        'gdbm-1.8.3-1-src.zip'
      ]
    )

    RubyGems = OpenStruct.new(
      :release => 'official',
      :version => '1.3.4',
      :url => 'http://rubyforge.org/frs/download.php/57643',
      :checkout => 'svn://rubyforge.org/var/svn/rubygems/trunk',
      :checkout_target => 'downloads/rubygems',
      :target => 'sandbox/rubygems',
      :configure_options => [
        '--no-ri',
        '--no-rdoc'
      ],
      :files => [
        'rubygems-1.3.4.tgz'
      ]
    )

    Wix = OpenStruct.new(
      :release => 'stable',
      :version => '2.0.5805.1',
      :url => 'http://downloads.sourceforge.net/wix',
      :target => 'sandbox/wix',
      :files => [
        'wix-2.0.5805.0-binaries.zip'
      ]
    )
    
    Paraffin = OpenStruct.new(
      :release => 'stable',
      :version => '2.0.5805.1',
      :url => 'http://www.wintellect.com/cs/files/folders/4332/download.aspx',
      :target => RubyInstaller::Wix.target,
      :files => [
        'Paraffin-1.03.zip'
      ]
    )

    Runtime18 = OpenStruct.new(
      :version => RubyInstaller::Ruby18.version,
      :ruby_version_source => RubyInstaller::Ruby18.target,
      :rubygems_version_source => RubyInstaller::RubyGems.target,
      :namespace => 'runtime18',
      :source => 'resources/installer',
      :package_name => 'rubyinstaller',
      :wix_config => {
          'ProductCode'=> "D7BFC0DB-2D60-4905-AFD4-87D05D70D7F2",
          'UpgradeCode'=> "419CB0D6-C20E-4553-B415-698427244883",
          'Year' =>  "2008-2009",
          'ProductName' =>  "Ruby Installer #{RubyInstaller::Ruby18.version}",
          'ProductVersion' =>  "",
          'InstallName' =>  "RubyInstaller",
          'InstallId' =>  "Ruby",
          'ProductURL' =>  "http://rubyinstaller.rubyforge.org/",
          'RuntimeTitle' =>  "Standard Ruby",
          'RuntimeDescription' =>  "Standard package including Ruby and libraries required for proper behavior of the language",
          'RubyTitle' =>  "Ruby + RubyGems",
          'RubyVersion' =>  "",
          'RubyDescription' =>  "Matz Ruby Implementation, standard library and RubyGems",
          'RubyGemsVersion' =>  ""
        },
      :wix_files => [
        'main.wxs',
        'ruby18_bin.wxs',
        'ruby18_lib.wxs',
        'ruby18_env.wxs'
      ],
      :config_file => 'config.wxi.erb'
    )

    Runtime19 = OpenStruct.new(
      :version => RubyInstaller::Ruby19.version,
      :ruby_version_source => RubyInstaller::Ruby19.target,
      :rubygems_version_source => RubyInstaller::RubyGems.target,
      :namespace => 'runtime19',
      :source => 'resources/installer',
      :package_name => 'rubyinstaller',
      :wix_config => {
          'ProductCode'=> "B1664535-125A-4164-851E-138DEC80B5D2",
          'UpgradeCode'=> "51626686-9EBF-48c5-A575-7C255DE3B5BF",
          'Year' =>  "2009",
          'ProductName' =>  "Ruby Installer #{RubyInstaller::Ruby19.version}",
          'ProductVersion' =>  "",
          'InstallName' =>  "RubyInstaller",
          'InstallId' =>  "Ruby19",
          'ProductURL' =>  "http://rubyinstaller.rubyforge.org/",
          'RuntimeTitle' =>  "Standard Ruby",
          'RuntimeDescription' =>  "Standard package including Ruby and libraries required for proper behavior of the language",
          'RubyTitle' =>  "Ruby",
          'RubyVersion' =>  "",
          'RubyDescription' =>  "Matz Ruby Implementation and standard library",
          'RubyGemsVersion' =>  ""
        },
      :wix_files => [
        'main.wxs',
        'ruby19_bin.wxs',
        'ruby19_include.wxs',
        'ruby19_lib.wxs',
        'ruby19_env.wxs'
      ],
      :config_file => 'config.wxi.erb'
    )
  end
end
