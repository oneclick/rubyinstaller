require 'ostruct'

module DevKitInstaller
  DEFAULT_VERSION = 'mingw64-32-4.7.2'
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
    :version => '2.3.0.16701.d6cd1b3-1-i686',
    :url_1 => 'http://downloads.sourceforge.net/msys2',
    :target => 'sandbox/devkit',
    :files => {
      :url_1 => [
        'msys2-runtime-2.3.0.16701.d6cd1b3-1-i686.pkg.tar.xz',
        'filesystem-2015.04-3-i686.pkg.tar.xz',
        'rebase-4.4.1-6-i686.pkg.tar.xz',
        'libiconv-1.14-2-i686.pkg.tar.xz',
        'libintl-0.19.6-1-i686.pkg.tar.xz',
        'ncurses-6.0.20151101-1-i686.pkg.tar.xz',
        'libreadline-6.3.008-6-i686.pkg.tar.xz',
        'gcc-libs-4.9.2-6-i686.pkg.tar.xz',
        'gmp-6.1.0-1-i686.pkg.tar.xz',
        'bash-4.3.042-2-i686.pkg.tar.xz',
        'coreutils-8.24-1-i686.pkg.tar.xz',
        'grep-2.22-1-i686.pkg.tar.xz',
        'libpcre-8.37-1-i686.pkg.tar.xz',
        'gawk-4.1.3-1-i686.pkg.tar.xz',
        'mpfr-3.1.3.p0-1-i686.pkg.tar.xz',
        'sed-4.2.2-2-i686.pkg.tar.xz',
        'diffutils-3.3-3-i686.pkg.tar.xz',
        'bison-3.0.4-1-i686.pkg.tar.xz',
        'm4-1.4.17-4-i686.pkg.tar.xz',
        'make-4.1-4-i686.pkg.tar.xz',
        'libguile-2.0.11-3-i686.pkg.tar.xz',
        'libcrypt-1.1-4-i686.pkg.tar.xz',
        'libffi-3.2.1-1-i686.pkg.tar.xz',
        'libgc-7.2.d-1-i686.pkg.tar.xz',
        'libltdl-2.4.6-1-i686.pkg.tar.xz',
        'libunistring-0.9.6-1-i686.pkg.tar.xz',
        'less-481-1-i686.pkg.tar.xz',
        'findutils-4.5.14-4-i686.pkg.tar.xz',
        'perl-5.22.0-2-i686.pkg.tar.xz',
        'mintty-1~2.2.1-1-i686.pkg.tar.xz',
        'autoconf-2.69-3-any.pkg.tar.xz',
        'automake1.15-1.15-2-any.pkg.tar.xz',
        'automake-wrapper-10-1-any.pkg.tar.xz',
        'libexpat-2.1.0-2-i686.pkg.tar.xz',
        'libtool-2.4.6-1-i686.pkg.tar.xz',
        'bsdtar-3.1.2-5-i686.pkg.tar.xz',
        'bsdcpio-3.1.2-5-i686.pkg.tar.xz',
        'libarchive-3.1.2-5-i686.pkg.tar.xz',
        'libbz2-1.0.6-2-i686.pkg.tar.xz',
        'liblzma-5.2.1-1-i686.pkg.tar.xz',
        'liblzo2-2.09-1-i686.pkg.tar.xz',
        'libnettle-3.1.1-1-i686.pkg.tar.xz',
        'libxml2-2.9.2-2-i686.pkg.tar.xz',
        'zlib-1.2.8-3-i686.pkg.tar.xz',
        'which-2.21-2-i686.pkg.tar.xz',
        'patch-2.7.5-1-i686.pkg.tar.xz',
        'tar-1.28-3-i686.pkg.tar.xz',
        'gzip-1.6-1-i686.pkg.tar.xz',
        'bzip2-1.0.6-2-i686.pkg.tar.xz',
        'xz-5.2.1-1-i686.pkg.tar.xz'
      ],
    }
  )

end
