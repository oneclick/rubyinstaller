require 'erb'
require 'rubygems'

interpreters = RubyInstaller::BaseVersions.collect { |ver|
  RubyInstaller.const_get("Ruby#{ver}")
}

begin
  gem 'rdoc', '~> 3.12'
  require 'rdoc/rdoc'
  gem 'rdoc_chm', '~> 3.1.0'
rescue Gem::LoadError
  if Rake.application.options.show_tasks
    puts "You need rdoc 3.12 and rdoc_chm 3.1.0 gems installed"
    puts "in order to build the docs tasks."
    puts "Try `gem install rdoc -v 3.12` and later `gem install rdoc_chm -v 3.1.0`"
    puts
  end
  interpreters = []
end

namespace :docs do
  task :htmlhelp do
    executable = 'hhc.exe'
    path = File.join(ENV['ProgramFiles'], 'HTML Help Workshop', executable)
    unless File.exist?(path) && File.executable?(path)
      puts <<-EOT
To generate CHM documentation you need Microsoft's Html Help Workshop installed.

You can download a copy for free from:

    http://www.microsoft.com/en-us/download/details.aspx?id=21138
EOT
      fail "HtmlHelp is required"
    end
  end
end

interpreters.each do |package|
  ruby_exe = File.join(package.install_target, "bin", "ruby.exe")
  next unless File.exist?(ruby_exe)

  info = RubyTools.parse_ruby(ruby_exe)
  next if info.empty?

  default_opts = ['--format=chm', '--encoding=UTF-8']
  meta_chm = package.meta_chm
  expanded_doc_target = File.join(RubyInstaller::ROOT, package.doc_target)

  package.docs.each do |doc|
    file doc.chm_file do 
      cd package.target do
        dirname = File.basename(doc.chm_file, '.chm')
        op_dir  = doc.target
        title   = "#{doc.title} API Reference"

        # create documentation
        args = default_opts +
              (doc.opts || []) +
              ['--title', title, '--op', op_dir] +
              doc.files

        rdoc = RDoc::RDoc.new
        rdoc.document(args)

        cp File.join(op_dir, File.basename(doc.chm_file)), doc.chm_file
      end
    end

    # meta package depends on individual chm files
    file meta_chm.file => [doc.chm_file]
  end

  # generate index
  index = File.join(expanded_doc_target, 'index.html')

  file index do
    cd package.doc_target do
      cp File.join(RubyInstaller::ROOT, 'resources', 'chm', 'README.txt'), '.'
      op_dir = File.join(expanded_doc_target, 'README')

      # create documentation
      opts = ['--op', op_dir, '--title', 'RubyInstaller', 'README.txt']
      rdoc = RDoc::RDoc.new
      rdoc.document(default_opts + opts)

      images = File.join(op_dir, 'images')
      js = File.join(op_dir, 'js')

      cp_r(images, expanded_doc_target) if File.exist?(images)
      cp_r(js, expanded_doc_target) if File.exist?(js)

      cp File.join(op_dir, 'rdoc.css'), expanded_doc_target
      cp File.join(op_dir, 'README_txt.html'), index
    end
  end

  # add index to the metapackge dependency
  file meta_chm.file => [index]

  # generate meta package
  file meta_chm.file do
    cd package.doc_target do

      meta_chm.files = Dir.glob('*.html')
      meta_chm.merge_files = Dir.glob('*.chm')
      source = File.join(RubyInstaller::ROOT, 'resources', 'chm', '*.rhtml')

      Dir.glob(source).each do |rhtml_file|
        File.open(File.basename(rhtml_file, '.rhtml'), 'w') do |output_file|
          output = ERB.new(File.read(rhtml_file), 0).result(binding)
          output_file.write(output)
        end
      end

      Dir.glob('*.hhp').each do |hhp|
        system RDoc::Generator::CHM::HHC_PATH, hhp
      end
    end
  end

  namespace "ruby#{info[:namespace_version]}" do
    task "docs:check_source" do
      unless File.exist? package.target
        fail "Source directory doesn't exist. Perhaps you built using LOCAL or CHECKOUT?"
      end
    end

    task :clobber_docs do
      rm_rf package.doc_target
    end

    desc "build docs for #{package.short_version}"
    task :docs => ['docs:htmlhelp', 'docs:check_source', meta_chm.file]

    desc "rebuild docs for #{package.short_version}"
    task :redocs => [:clobber_docs, :docs]
  end
end
