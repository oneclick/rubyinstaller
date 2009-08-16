require 'erb'
require 'rubygems'

interpreters = [RubyInstaller::Ruby18, RubyInstaller::Ruby19]

begin
  gem 'rdoc', '>= 2.4.0'
  require 'rdoc/rdoc'
  gem 'rdoc_chm', '>= 2.4.0'
rescue Gem::LoadError
  if Rake.application.options.show_tasks
    puts "You need the rdoc and rdoc_chm gems installed"
    puts "in order to build the docs tasks."
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

    http://msdn.microsoft.com/library/default.asp?url=/library/en-us/htmlhelp/html/hwMicrosoftHTMLHelpDownloads.asp
EOT
      fail "HtmlHelp is required"
    end
  end
end
interpreters.each do |package|

  short_ver    = package.version.gsub('.', '')[0..1]
  version      = "ruby#{short_ver}"  
  version_dir  = File.basename(package.target)
  doc_dir      = File.join(RubyInstaller::ROOT, 'sandbox', 'doc')
  target       = File.join(doc_dir, version_dir)
  
  core_glob    = File.join(RubyInstaller::ROOT, package.target, "*.c")
  core_files   = Dir[core_glob].map{|f| File.basename(f) }
  
  stdlib_files = ['./lib', './ext']


  namespace(version) do

    rdocs=[
            {
              :file  => "#{version}-core.chm",
              :title => "Ruby #{package.version} Core",
              :files => core_files,
            },
            {
              :file  => "#{version}-stdlib.chm",
              :title => "Ruby #{package.version} Standard Library",
              :files => stdlib_files,
              :opts  => ["-x", "./lib/rdoc"]
            }
          ]

      meta_chm = OpenStruct.new(
        :title => "Ruby #{package.version} Help file",
        :file  => File.join(target, "#{version}.chm")
      )
        
    namespace(:docs) do
      
      default_opts = ['--line-numbers', '--format=chm']

      rdocs.each do |chm|
        
        chm_file = File.join(target,chm[:file])
        
        file chm_file do
          cd package.target do
            dirname = File.basename(chm_file,'.chm')
            op_dir  = File.join(target, dirname)
            title   = "#{chm[:title]} API Reference"
            
            # create documentation          
            args = default_opts + 
                  (chm[:opts] || []) + 
                  ['--title', title ,'--op',op_dir] + 
                  chm[:files]  
                  
            rdoc = RDoc::RDoc.new
            rdoc.document(args)
            
            
            cp File.join(op_dir, File.basename(chm[:file])), chm_file
          end
        end
        
        task :rdocs, :needs => chm_file

      end
      
      index = File.join(target, 'index.html')
      
      file index do
        cd target do
          cp File.join(RubyInstaller::ROOT, 'resources', 'chm', 'README.txt'), '.'
          op_dir = File.join(target, 'README')
  
          # create documentation
          opts = ['--op', op_dir,'--title', 'RubyInstaller', 'README.txt']
          rdoc = RDoc::RDoc.new
          rdoc.document(default_opts + opts)
  
          images = File.join(op_dir, 'images')
          js = File.join(op_dir, 'js')
  
          cp_r(images, target) if File.exist?(images)
          cp_r(js, target) if File.exist?(js)
  
          cp File.join(op_dir, 'rdoc.css'), target
          cp File.join(op_dir, 'README_txt.html'), index
        end
      end

      file meta_chm.file, 
        :needs => File.join(target, 'index.html') do
        
        cd target do
          
          meta_chm.files = Dir['*.html']
          meta_chm.merge_files = Dir['*.chm']
          source = File.join(RubyInstaller::ROOT, 'resources', 'chm', '*.rhtml')
          
          Dir[source].each do |rhtml_file| 
          
            File.open(File.basename(rhtml_file, '.rhtml'),'w+') do |output_file|
              output = ERB.new(File.read(rhtml_file), 0).result(binding)
              output_file.write(output)
            end
          
          end
  
          Dir['*.hhp'].each{|hhp| system(RDoc::Generator::CHM::HHC_PATH, hhp) }
        
        end

      end
     
    end

    task :clobber_docs do
      rm_rf target
    end
    
    desc "build docs for #{version}"
    task :docs, :needs => ["docs:htmlhelp", "docs:rdocs", meta_chm.file]

    desc "rebuild docs for #{version}"
    task :redocs, :needs => [:clobber_docs, :docs]

  end

end
