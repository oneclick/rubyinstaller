require 'erb'

module RubyTools
  # read C definitions from 'target' file and return
  # a hash of values
  def self.ruby_version(target)
    return nil unless File.exist?(target)

    h = {}
    version_file = File.read(target)
    h[:version] = /RUBY_VERSION "(.+)"$/.match(version_file)[1]
    h[:patchlevel] = /RUBY_PATCHLEVEL (.+)$/.match(version_file)[1]

    # keep Inno's VersionInfoVersion happy for Ruby trunk builds
    h[:patchlevel] = '9999' if h[:patchlevel].to_i < 0

    # check presence of RUBY_VERSION_CODE (only in 1.8.7) as proxy for
    # RUBY_LIB_VERSION_STYLE == {2,3} check
    if version_file =~ /RUBY_VERSION_CODE (.+)$/
      h[:lib_version] = h[:version][0..2]
    else
      if version_file =~ /RUBY_API_VERSION_TEENY/
        # support Ruby 1.9.3 version info
        alt_target = File.join(File.dirname(target), 'include', 'ruby', 'version.h')
        alt_version_file = File.read(alt_target)
        teeny = /RUBY_API_VERSION_TEENY (.+)$/.match(alt_version_file)[1]
      else
        # support 1.9.1 and 1.9.2 version info
        teeny = /RUBY_VERSION_TEENY (.+)$/.match(version_file)[1]
      end
      h[:lib_version] = "#{h[:version][0..2]}.#{teeny}"
    end
    h
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
  #     :sign             => ENV['SIGNED']
  #   )
  #
  # will be converted into a shell command line similar to:
  #
  #   iscc.exe rubyinstaller.iss /dRubyPatch=429 /dRubyPath=C:/.../sandbox/ruby
  #       /dRubyVersion=1.9.2 /dRubyLibVersion=1.9.1 /dNoTk=true
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

[RubyInstaller::Ruby18, RubyInstaller::Ruby19].each do |pkg|
  # skip iteration to prevent aliasing when using ENV['LOCAL']
  next unless "ruby#{pkg.version[0..2].gsub('.','')}" ==
    Rake.application.top_level_tasks.first.split(':')[0].downcase

  if info = RubyTools.ruby_version(File.join(pkg.target, 'version.h'))
    version       = "#{info[:version]}-p#{info[:patchlevel]}"
    version_xyz   = info[:version]
    major_minor   = info[:version][0..2]
    namespace_ver = major_minor.sub('.', '')
    version       << "-#{ENV['RELEASE']}" if ENV['RELEASE']
    installer_pkg = "rubyinstaller-#{version}"

    # FIXME remove config-#{major_minor}.iss as this file is dynamically
    #       created in installer file task below
    files = FileList[
      'resources/installer/rubyinstaller.iss',
      "resources/installer/config-#{version_xyz}.iss"
    ]

    file "resources/installer/config-#{version_xyz}.iss" => ['resources/installer/config.iss.erb'] do |t|
      guid = pkg.installer_guid
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
    file "pkg/#{installer_pkg}.exe" => ['pkg', "ruby#{namespace_ver}:docs", :book, *files] do
      options = {
        :ruby_version     => info[:version],
        :ruby_lib_version => info[:lib_version],
        :ruby_patch       => info[:patchlevel],
        :ruby_path        => File.expand_path(pkg.install_target),
        :output           => 'pkg',
        :filename         => installer_pkg,
        :sign             => ENV['SIGNED']
      }
      options[:no_tk] = true if ENV['NOTK']

      InnoSetup.iscc("resources/installer/rubyinstaller.iss", options)
    end

    # define the packaging task for the version
    namespace "ruby#{namespace_ver}" do
      desc "generate #{installer_pkg}.exe"
      task :package => [:innosetup, "pkg/#{installer_pkg}.exe"]

      desc "install #{installer_pkg}.exe"
      task :install => [:package] do
        sh "pkg/#{installer_pkg}.exe /LOG=pkg/#{installer_pkg}.log"
      end

      task :clobber do
        rm_f "resources/installer/config-#{version_xyz}.iss"
        rm_f "pkg/#{installer_pkg}.exe"
      end

      desc "rebuild #{installer_pkg}.exe"
      task :repackage => [:clobber, :package]
    end
  end
end
