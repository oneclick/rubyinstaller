require 'ostruct'

module RubyInstaller
  unless defined?(ROOT)
    # Root folder
    ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))

    # Console based utilities
    SEVEN_ZIP = File.expand_path(File.join(ROOT, 'sandbox', 'extract_utils', '7za.exe'))
    BSD_TAR = File.expand_path(File.join(ROOT, 'sandbox', 'extract_utils', 'basic-bsdtar.exe'))

    # SSL Certificates
    Certificate = OpenStruct.new(
      :url  => 'http://curl.haxx.se/ca',
      :file => 'cacert.pem'
    )

    Ruby18 = OpenStruct.new(
      :version => '1.8.7-p371',
      :short_version => 'ruby18',
      :url => "http://ftp.ruby-lang.org/pub/ruby/1.8",
      :checkout => 'http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_8_7',
      :checkout_target => 'downloads/ruby_1_8',
      :target => 'sandbox/ruby_1_8',
      :doc_target => 'sandbox/doc/ruby18',
      :build_target => 'sandbox/ruby18_build',
      :install_target => 'sandbox/ruby18_mingw',
      :patches => 'resources/patches/ruby187',
      :configure_options => [
        '--enable-shared',
        '--with-winsock2',
        '--disable-install-doc',
        "CFLAGS='-g -O2 -DFD_SETSIZE=256'"
      ],
      :files => [
        'ruby-1.8.7-p371.tar.bz2'
      ],
      :dependencies => [
        :gdbm, :iconv, :openssl, :pdcurses, :zlib, :tcl, :tk
      ],
      :excludes => [
        'libcharset-1.dll'
      ],
      :installer_guid => '{F6377277-9DF1-4a1f-A487-CB5D34DCD793}'
    )

    # switch to Ruby 1.8.6 for "1.8" branch at runtime
    if ENV['COMPAT'] then
      Ruby18.version = '1.8.6-p398'
      Ruby18.checkout = 'http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_8_6'
      Ruby18.files = ['ruby-1.8.6-p398.tar.bz2']
      Ruby18.patches = nil
      Ruby18.installer_guid = '{CE65B110-8786-47EA-A4A0-05742F29C221}'
    end

    Ruby19 = OpenStruct.new(
      :version => "1.9.3-p286",
      :short_version => 'ruby19',
      :url => "http://ftp.ruby-lang.org/pub/ruby/1.9",
      :checkout => 'http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_9_3',
      :checkout_target => 'downloads/ruby_1_9',
      :target => 'sandbox/ruby_1_9',
      :doc_target => 'sandbox/doc/ruby19',
      :build_target => 'sandbox/ruby19_build',
      :install_target => 'sandbox/ruby19_mingw',
      :patches => 'resources/patches/ruby193',
      :configure_options => [
        '--enable-shared',
        '--disable-install-doc',
        'debugflags=-g',
        "CPPFLAGS='-DFD_SETSIZE=2048'"
      ],
      :files => [
        'ruby-1.9.3-p286.tar.bz2'
      ],
      :dependencies => [
        :ffi, :gdbm, :iconv, :openssl, :pdcurses, :yaml, :zlib, :tcl, :tk
      ],
      :excludes => [
        'libcharset-1.dll'
      ],
      :installer_guid => '{17E73B15-62D2-43FD-B851-ACF86A8C9D25}',
      :installer_guid_x64 => '{74C4327B-E042-4B03-A8BA-482FD66BEEDB}'
    )

    # COMPAT mode for Ruby 1.9.2
    if ENV['COMPAT'] then
      Ruby19.version = "1.9.2-p290"
      Ruby19.checkout = 'http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_9_2'
      Ruby19.files = ['ruby-1.9.2-p290.tar.bz2']
      Ruby19.installer_guid = '{BD5F3A9C-22D5-4C1D-AEA0-ED1BE83A1E67}'
    end

    # OBSOLETE for Ruby 1.9.1
    if ENV["OBSOLETE"]
      Ruby19.version = '1.9.1-p430'
      Ruby19.checkout = 'http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_9_1'
      Ruby19.files = ['ruby-1.9.1-p430.tar.bz2']
      Ruby19.dependencies = [:gdbm, :iconv, :openssl, :pdcurses, :zlib]
      Ruby19.patches = nil
      Ruby19.installer_guid = '{11233A17-BFFC-434A-8FC8-2E93369AF008}'
    end

    # Modify relevent configuration metadata when building from a
    # local repository
    if ENV['LOCAL'] then
      Ruby18.installer_guid = '{12E6FD2D-D425-4E32-B77B-020A15A8346F}'
      Ruby18.target = File.expand_path(ENV['LOCAL'].gsub('\\', File::SEPARATOR))

      Ruby19.patches = nil
      Ruby19.target = File.expand_path(ENV['LOCAL'].gsub('\\', File::SEPARATOR))
      Ruby19.installer_guid = '{17E73B15-62D2-43FD-B851-ACF86A8C9D25}'
    end

    # alter at runtime the checkout and versions of 1.9
    if ENV['TRUNK'] then
      Ruby19.version = '2.0.0'
      Ruby19.checkout = 'http://svn.ruby-lang.org/repos/ruby/trunk'
      Ruby19.installer_guid = "{270FF09A-DC07-499D-B5D7-C4F5A30EDC83}"
    end

    # do not build or prepare any dependency library
    if ENV['NODEPS'] then
      Ruby18.dependencies.clear
      Ruby19.dependencies.clear
    end

    # do not build Tk extension or supporting libraries
    if ENV['NOTK'] then
      [:tcl, :tk].each do |pkg|
        Ruby18.dependencies.delete(pkg)
        Ruby19.dependencies.delete(pkg)
      end
    end

    RubyGems = OpenStruct.new(
      :release => 'official',
      :version => '1.8.24',
      :url => 'http://rubyforge.org/frs/download.php/76073',
      :checkout => 'http://github.com/rubygems/rubygems.git',
      :checkout_target => 'downloads/rubygems',
      :target => 'sandbox/rubygems',
      :configure_options => [
        '--no-ri',
        '--no-rdoc'
      ],
      :files => [
        'rubygems-1.8.24.tgz'
      ],
      :hooks => [
        'resources/rubygems/operating_system.rb'
      ]
    )

    Book = OpenStruct.new(
      :release => 'official',
      :version => '2009-04-18',
      :url => 'http://www.sapphiresteel.com/IMG/zip',
      :target => 'sandbox/book',
      :files => [
        'book-of-ruby.zip'
      ]
    )
  end
end
