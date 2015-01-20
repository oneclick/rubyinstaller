require 'erb'
require "digest/md5"
require "digest/sha2"

module PkgTools
  def self.digests(file_name)
    md5_file(file_name)
    sha256_file(file_name)
  end

  # create a companion MD5 checksum file for the file named by file_name
  # format: hex_md5_checksum *file_basename
  def self.md5_file(file_name)
    File.open("#{file_name}.md5", "w") do |f|
      f.puts '%s *%s' % [ Digest::MD5.file(file_name), File.basename(file_name) ]
    end
  end

  def self.sha256_file(file_name)
    File.open("#{file_name}.sha256", "w") do |f|
      f.puts '%s *%s' % [Digest::SHA256.file(file_name), File.basename(file_name)]
    end
  end
end

# TODO: port this to it's own innosetup recipe
module InnoSetup
  extend Rake::DSL if defined?(Rake::DSL)

  EXECUTABLE = "iscc.exe"

  def self.present?
    candidate = ENV['PATH'].split(File::PATH_SEPARATOR).detect do |path|
      File.exist?(File.join(path, EXECUTABLE)) &&
        File.executable?(File.join(path, EXECUTABLE))
    end

    return true if candidate
  end

  # Generates and runs the shell command required to build an InnoSetup
  # installer. An option hash provided as the last argument will have all
  # its keys (except :output, :filename, and :sign) converted into Inno
  # command line /d name/value pairs.
  #
  # The option hash must use lower cased symbols (underlined for multiple
  # words) which will be converted to UpperCamelCase command line args.
  #
  # Example - the following method call
  #
  #   InnoSetup.iscc('rubyinstaller.iss',
  #     :ruby_version     => '1.9.2',
  #     :ruby_lib_version => '1.9.1'
  #     :ruby_patch       => '429',
  #     :ruby_path        => File.expand_path('sandbox/ruby'),
  #     :output           => 'pkg',
  #     :filename         => 'rubyinstaller-1.9.2-p429',
  #     :no_tk            => true,
  #     :no_docs          => true,
  #     :sign             => ENV['SIGNED']
  #   )
  #
  # will be converted into a shell command line similar to:
  #
  #   iscc.exe rubyinstaller.iss /dRubyPatch=429 /dRubyPath=C:/.../sandbox/ruby
  #       /dRubyVersion=1.9.2 /dRubyLibVersion=1.9.1 /dNoTk=true /dNoDocs=true
  #       /opkg /frubyinstaller-1.9.2-p429
  #
  def self.iscc(script, *args)
    non_arg_options = [:output, :filename, :sign]
    cmd = []
    options = args.last || {}

    cmd << EXECUTABLE
    cmd << script

    options.each do |k,v|
      cmd << "/d#{k.to_s.camelcase}=#{v}" unless non_arg_options.include?(k)
    end unless options.empty?

    cmd << "/o#{options[:output]}" if options[:output]
    cmd << "/f#{options[:filename]}" if options[:filename]

    if options[:sign] then
      cmd << "/dSignPackage=1"
      cmd << '/s"risigntool=signtool.exe $p"'
    end

    sh cmd.join(' ')
  end
end

# A fake task for now that ensures innosetup is on the PATH,
# and if not, add %ProgramFiles%\Inno Setup 5
task :innosetup do
  unless InnoSetup.present?
    # if not found, add InnoSetup to the PATH
    path = File.join(ENV['ProgramFiles'], 'Inno Setup 5')
    path.gsub!(File::SEPARATOR, File::ALT_SEPARATOR)
    ENV['PATH'] = "#{ENV['PATH']}#{File::PATH_SEPARATOR}#{path}"
  end

  fail "You need InnoSetup installed" unless InnoSetup.present?
end

# Certificate signing tool (signtool.exe) check
# TODO: move this out

module SignTool
  EXECUTABLE = "signtool.exe"

  def self.present?
    candidate = ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      File.exist?(File.join(path, EXECUTABLE)) &&
        File.executable?(File.join(path, EXECUTABLE))
    end

    return true if candidate
  end
end

task :signtool do
  unless SignTool.present?
    fail "You need #{SignTool::EXECUTABLE} present to sign your installer"
  end
end

# if SIGNED was specified, chain signtool verification to innosetup check
if ENV['SIGNED'] then
  task :innosetup => [:signtool]
end

directory 'pkg'

interpreters = RubyInstaller::BaseVersions.collect { |ver|
  RubyInstaller.const_get("Ruby#{ver}")
}

interpreters.each do |pkg|
  ruby_exe = File.join(pkg.install_target, "bin", "ruby.exe")
  next unless File.exist?(ruby_exe)

  # if info = RubyTools.ruby_version(File.join(pkg.target, 'version.h'))
  if info = RubyTools.parse_ruby(ruby_exe)
    version       = info[:version].dup
    platform      = info[:platform]

    # Ruby 2.1.0 introduced semantic versioning, so we drop patchlevel
    if version < "2.1.0"
      # construct either X.Y.Z-p123 or X.Y.Z-rNNNN (dev)
      if info[:patchlevel]
        version     << "-p%s" % info[:patchlevel]
      else
        version     << "-r%s" % info[:revision]
      end
    end

    version_xyz   = info[:version]
    major_minor   = info[:version][0..2]
    namespace_ver = major_minor.sub('.', '')

    if version < "2.1.0"
      version_dir = version_xyz.gsub(".", "")
    else
      version_dir = namespace_ver
    end

    # i386-mingw32, x64-mingw32
    case platform
    when "i386-mingw32"
      guid            = pkg.installer_guid
      limit_platforms = ""
      short_platform  = ""
    when "x64-mingw32"
      guid            = pkg.installer_guid_x64
      limit_platforms = "x64"
      short_platform  = "-x64"
      version         << short_platform
    end

    installer_pkg = "rubyinstaller-%s" % version

    # FIXME remove config-#{major_minor}.iss as this file is dynamically
    #       created in installer file task below
    files = FileList[
      'resources/installer/rubyinstaller.iss',
      "resources/installer/config-#{version_xyz}-#{platform}.iss"
    ]

    file "resources/installer/config-#{version_xyz}-#{platform}.iss" => ['resources/installer/config.iss.erb'] do |t|
      contents = ERB.new(File.read(t.prerequisites.first)).result(binding)

      when_writing("Generating #{t.name}") do
        File.open(t.name, 'w') { |f| f.write contents }
      end
    end

    file 'resources/installer/changes.txt' => ['pkg', 'History.txt'] do |t|
      contents = File.read('History.txt')
      latest = contents.split(/^(===+ .*)/)[1..2].join.strip

      when_writing('Generating changes file...') do
        File.open(t.name, 'w') { |f| f.write latest }
      end
    end

    # installer
    if ENV['NODOCS']
      installer_deps = ['pkg', *files]
    else
      installer_deps = ['pkg', "ruby#{namespace_ver}:docs", :book, *files]
    end
    file "pkg/#{installer_pkg}.exe" => installer_deps do |t|
      options = {
        :ruby_version        => info[:version],
        :ruby_lib_version    => info[:lib_version],
        :ruby_patch          => info[:patchlevel] || info[:revision],
        :ruby_path           => File.expand_path(pkg.install_target),
        :ruby_build_platform => info[:platform],
        :ruby_short_platform => short_platform,
        :output              => 'pkg',
        :filename            => installer_pkg,
        :sign                => ENV['SIGNED']
      }
      options[:no_tk] = true if ENV['NOTK']
      options[:no_docs] = true if ENV['NODOCS']

      InnoSetup.iscc("resources/installer/rubyinstaller.iss", options)

      # Generate digest files
      PkgTools.digests(t.name)
    end

    # archives (engine-version-patchlevel|revision-platform.7z)
    package_name = "ruby"
    package_name << "-%s" % info[:version]

    if info[:version] < "2.1.0" || ENV['FULL_VERSION']
      if info[:patchlevel]
        package_name << "-p%s" % info[:patchlevel]
      else
        package_name << "-r%s" % info[:revision]
      end
    end

    package_name << "-%s" % info[:platform]

    file "pkg/#{package_name}/bin/ruby.exe" => [pkg.install_target] do
      dir = "pkg/#{package_name}"

      # remove target
      rm_rf dir if File.directory?(dir)
      cp_r pkg.install_target, dir
    end

    file "pkg/#{package_name}.7z" => ["pkg", "pkg/#{package_name}/bin/ruby.exe"] do |t|
      cd File.dirname(t.name) do
        seven_zip_build "#{package_name}", File.basename(t.name)
      end

      # Generate digest files
      PkgTools.digests(t.name)
    end

    # documentation (engine-version-doc-chm.7z)
    docs_name = "ruby"
    docs_name << "-%s" % info[:version]

    if info[:version] < "2.1.0"
      if info[:patchlevel]
        docs_name << "-p%s" % info[:patchlevel]
      else
        docs_name << "-r%s" % info[:revision]
      end
    end

    docs_name << "-doc-chm"
    doc_files = pkg.docs.collect { |doc| doc.chm_file }
    doc_files << pkg.meta_chm.chm_file

    file "pkg/#{docs_name}.7z" => ["pkg", "ruby#{namespace_ver}:docs", *doc_files] do |t|
      cd File.dirname(t.name) do
        seven_zip_multi doc_files, "#{docs_name}.7z"
      end

      # generate digest files
      PkgTools.digests(t.name)
    end

    # define the packaging task for the version
    namespace "ruby#{namespace_ver}" do
      desc "generate packages for ruby #{version}"
      task :package => ["package:installer", "package:archive"]

      unless ENV["NODOCS"]
        task :package => ["package:docs"]
      end

      namespace :package do
        desc "generate #{installer_pkg}.exe"
        task :installer => [:innosetup, "pkg/#{installer_pkg}.exe"]

        desc "generate #{package_name}.7z"
        task :archive => ["pkg/#{package_name}.7z"]

        desc "generate #{docs_name}.7z"
        task :docs => ["pkg/#{docs_name}.7z"]
      end

      desc "install #{installer_pkg}.exe"
      task :install => ["package:installer"] do
        sh "pkg/#{installer_pkg}.exe /LOG=pkg/#{installer_pkg}.log"
      end

      task :clean do
        rm_f "resources/installer/config-#{version_xyz}-#{platform}.iss"
        rm_f "pkg/#{installer_pkg}.exe"
      end

      desc "rebuild #{installer_pkg}.exe"
      task :repackage => [:clean, :package]
    end
  end
end
