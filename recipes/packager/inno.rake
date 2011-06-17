require 'erb'

module RubyTools
  # use provided ruby.exe to figure out runtime information
  def self.parse_ruby(ruby_exe)
    result = `#{ruby_exe} -rrbconfig -ve \"puts 'ruby_version: %s' % RbConfig::CONFIG['ruby_version']\"`
    return nil unless $?.success?
    return nil if result.empty?

    h = {}

    if result =~ /(\d\.\d.\d)/
      h[:version] = $1
    end

    if result =~ /patchlevel (\d+)/
      h[:patchlevel] = $1
    end

    if result =~ /\dp(\d+)/
      h[:patchlevel] = $1
    end

    if result =~ /ruby_version: (\S+)/
      h[:lib_version] = $1
    end

    if result =~ /\[(\S+)\]/
      h[:platform] = $1
    end

    if result =~ /trunk (\d+)/
      h[:revision] = $1
    end

    if result =~ /(\d+-\d+-\d+)/
      h[:release_date] = $1
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
  ruby_exe = File.join(pkg.install_target, "bin", "ruby.exe")
  next unless File.exist?(ruby_exe)

  # if info = RubyTools.ruby_version(File.join(pkg.target, 'version.h'))
  if info = RubyTools.parse_ruby(ruby_exe)
    version       = info[:version].dup

    # construct either X.Y.Z-p123 or X.Y.Z-rNNNN (dev)
    if info[:patchlevel]
      version     << "-p%s" % info[:patchlevel]
    else
      version     << "-r%s" % info[:revision]
    end

    version_xyz   = info[:version]
    major_minor   = info[:version][0..2]
    namespace_ver = major_minor.sub('.', '')

    # i386-mingw32, x86_64-mingw32
    case info[:platform]
    when "i386-mingw32"
      # noop
    when "x86_64-mingw32"
      version     << "-x64"
    end

    installer_pkg = "rubyinstaller-%s" % version

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
        :ruby_patch       => info[:patchlevel] || info[:revision],
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
      desc "generate packages for ruby #{version}"
      task :package => ["package:installer"]

      namespace :package do
        desc "generate #{installer_pkg}.exe"
        task :installer => [:innosetup, "pkg/#{installer_pkg}.exe"]
      end

      desc "install #{installer_pkg}.exe"
      task :install => ["package:installer"] do
        sh "pkg/#{installer_pkg}.exe /LOG=pkg/#{installer_pkg}.log"
      end

      task :clean do
        rm_f "resources/installer/config-#{version_xyz}.iss"
        rm_f "pkg/#{installer_pkg}.exe"
      end

      desc "rebuild #{installer_pkg}.exe"
      task :repackage => [:clean, :package]
    end
  end
end
