module RubyTools
  # read C definitions from 'target' file and return
  # a hash of values
  def self.ruby_version(target)
    return nil unless File.exist?(target)
    h = {}
    version_file = File.read(target)
    h[:version] = /RUBY_VERSION "(.+)"$/.match(version_file)[1]
    h[:patchlevel] = /RUBY_PATCHLEVEL (.+)$/.match(version_file)[1]
    h
  end
end

# TODO: port this to it's own innosetup recipe
module InnoSetup
  EXECUTABLE = "iscc.exe"

  def self.present?
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      return true if File.exist?(File.join(path, EXECUTABLE)) && File.executable?(File.join(path, EXECUTABLE))
    end
    false
  end

  def self.iscc(script, *args)
    cmd = []
    options = args.last || {}

    cmd << EXECUTABLE
    cmd << script
    cmd << "/dRubyVersion=#{options[:ruby_version]}"
    cmd << "/dRubyPatch=#{options[:ruby_patch]}"
    cmd << "/dRubyPath=#{options[:ruby_path]}"
    cmd << "/o#{options[:output]}" if options[:output]
    cmd << "/f#{options[:filename]}" if options[:filename]

    sh cmd.join(' ')
  end
end

# A fake task for now that ensures innosetup is no the PATH,
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

directory 'pkg'

[RubyInstaller::Ruby18, RubyInstaller::Ruby19].each do |pkg|
  if info = RubyTools.ruby_version(File.join(pkg.target, 'version.h'))
    version       = "#{info[:version]}-p#{info[:patchlevel]}"
    major_minor   = info[:version][0..2]
    namespace_ver = major_minor.sub('.', '')
    installer_pkg = "rubyinstaller-#{version}"

    files = FileList[
      "resources/installer/rubyinstaller.iss",
      "resources/installer/config-#{major_minor}.iss"
    ]

    # installer
    file "pkg/#{installer_pkg}.exe",
      :needs => ['pkg', "ruby#{namespace_ver}:docs", *files] do

      InnoSetup.iscc("resources/installer/rubyinstaller.iss",
        :ruby_version => info[:version],
        :ruby_patch   => info[:patchlevel],
        :ruby_path    => pkg.install_target,
        :output       => 'pkg',
        :filename     => installer_pkg
      )
    end

    # define the packaging task for the version
    namespace "ruby#{namespace_ver}" do
      desc "generate #{installer_pkg}.exe"
      task :package, :needs => [:innosetup, "pkg/#{installer_pkg}.exe"]

      desc "install #{installer_pkg}.exe"
      task :install, :needs => [:package] do
        sh "pkg/#{installer_pkg}.exe /LOG=pkg/#{installer_pkg}.log"
      end

      task :clobber do
        rm_f "pkg/#{installer_pkg}.exe"
      end

      desc "rebuild #{installer_pkg}.exe"
      task :repackage, :needs => [:clobber, :package]
    end
  end
end
