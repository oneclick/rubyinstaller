require 'rake'
require 'rake/clean'
require 'pathname'

namespace(:interpreter) do
  namespace(:rbx) do
    package = RubyInstaller::Rubinius
    directory package.install_target
    CLEAN.include(package.install_target)

    # Put files for the :download task
    package.files.each do |f|
      file_source = "#{package.url}/#{f}"
      file_target = "downloads/#{f}"
      download file_target => file_source

      # depend on downloads directory
      file file_target => "downloads"

      # download task need these files as pre-requisites
      task :download => file_target
    end

    task :checkout => "downloads" do
      cd RubyInstaller::ROOT do
        # If is there already a checkout, update instead of checkout
        if File.exist?(File.join(RubyInstaller::ROOT, package.checkout_target, '.git'))
          Dir.chdir(package.checkout_target) do
            sh "cmd /c \"git checkout #{package.branch} && git pull\""
          end
        else
          sh "git clone #{package.checkout} #{package.checkout_target} --branch #{package.branch}"
        end
      end
    end

    task :sources do
      case
      when ENV['LOCAL']
      when ENV['CHECKOUT']
        Rake::Task['interpreter:rbx:checkout'].invoke
      else
        Rake::Task['interpreter:rbx:download'].invoke
      end
    end

    task :extract => [:extract_utils] do
      case
      when ENV['LOCAL']
        package.target = File.expand_path(File.join(ENV['LOCAL'], '.'))
      when ENV['CHECKOUT']
        package.target = File.expand_path(package.checkout_target)
      else
        # grab the files from the download task
        files = Rake::Task['interpreter:rbx:download'].prerequisites

        # ensure target directory exist
        mkdir_p package.target

        files.each { |f|
          extract(File.join(RubyInstaller::ROOT, f), package.target, :noerror => true)
        }
      end
    end

    task :configure => [:extract, :compiler, *package.dependencies] do
      unless uptodate?(File.join(package.target, 'config.rb'), [File.join(package.target, 'configure')])
        cd package.target do
          ruby "configure #{package.configure_options.join(' ')} --prefix=#{File.join(RubyInstaller::ROOT, package.install_target)}"
        end
      end
    end

    task :compile => [:configure, :compiler, *package.dependencies] do
      cd package.target do
        sh "rake"
      end
    end

    task :install => [ package.install_target, *package.dependencies ] do
      full_install_target = File.expand_path(File.join(RubyInstaller::ROOT, package.install_target))

      # perform make install
      cd package.build_target do
        sh "rake install"
      end

      # copy the DLLs from the listed dependencies
      paths = ENV['PATH'].split(';')
      package.dependencies.each do |dep|
        if dir = paths.find { |p| p =~ /#{dep.to_s}/ }
          Dir.glob("#{File.expand_path(dir)}/*.dll").each do |path|
            next if package.excludes.include?(File.basename(path))
            cp path, File.join(package.install_target, "bin")
          end
        end
      end
    end
  end
end

desc "compile Rubinius"
task :rbx => [
  'interpreter:rbx:sources',
  'interpreter:rbx:extract',
  'interpreter:rbx:configure',
  'interpreter:rbx:compile',
#  'interpreter:rbx:install'
]
