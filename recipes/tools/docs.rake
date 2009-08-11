require 'erb'
require 'rubygems'

require 'rdoc/rdoc'


{:ruby18 => RubyInstaller::Ruby18, 
:ruby19 => RubyInstaller::Ruby19}.each do |version, package|
  namespace(version) do
    
    target = File.join(RubyInstaller::ROOT, 'sandbox', 'doc', File.basename(package.target) )
    
    namespace(:docs) do

      default_opts = ['--line-numbers', '--format=chm']
  
      rdocs={
          "#{version}-core" => {
            :file  => "#{version}-core.chm",
            :title => "Ruby #{package.version} Core API Reference",
            :files => Dir[File.join(RubyInstaller::ROOT, package.target, "*.c")].map{|f| File.basename(f) },
          },
          "#{version}-stdlib" => {
            :file  => "#{version}-stdlib.chm",
            :title => "Ruby #{package.version} Standard Library API Reference",
            :files => ['./lib', './ext'],
            :opts  => ["-x", "./lib/rdoc"]
          }
        }

      rdocs.each do |name, chm|
        
        chm_file = File.join(target,chm[:file])
        
        file chm_file do
          cd package.target do
            op = File.join(target, name)
          
            #create documentation          
            args = default_opts + (chm[:opts] || []) + ['--title',chm[:title],'--op',op] + chm[:files]  
            rdoc = RDoc::RDoc.new
            rdoc.document(args)
            
            
            cp File.join(op, File.basename(chm[:file])), chm_file
          end
        end
        
        task :docs => chm_file

      end
      
      task :readme do
        cp File.join(RubyInstaller::ROOT, 'resources', 'chm', 'readme.rdoc'), '.'
        op = op = File.join(target, 'README')
      
        #create documentation          
        args = default_opts + ['--op',op,'--title', 'README', 'README.rdoc']  
        rdoc = RDoc::RDoc.new
        rdoc.document(args)
        cp_r File.join(op, 'images'), target
        cp_r File.join(op, 'js'), target
        cp File.join(op, 'rdoc.css'), target
        cp File.join(op, 'README_rdoc.html'), File.join(target, 'index.html')
      end

      meta_chm = OpenStruct.new(
        :title => "Ruby #{package.version} Help file",
        :file  => File.join(target, "#{version.to_s}.chm")
      )


      file meta_chm.file => :readme do
        cd target do
          meta_chm.files = Dir['*.html']
          meta_chm.merge_files = Dir['*.chm']
          Dir[File.join(RubyInstaller::ROOT, 'resources', 'chm', '*.rhtml')].each do |rhtml_file| 
            File.open(File.basename(rhtml_file, '.rhtml'),'w+') do |output_file|
              output = ERB.new(File.read(rhtml_file), 0).result(binding)
              output_file.write(output)
            end
          end
  
          Dir['*.hhp'].each{|hhp| system(RDoc::Generator::CHM::HHC_PATH, hhp) }
        end

      end
     
      task :meta_doc => meta_chm.file
    end

    task :clobber_docs do
      rm_rf target
    end
     
    desc "build docs for #{version}"
    task :docs => ["docs:docs", "docs:meta_doc"]


    desc "rebuild docs for #{version}"
    task :redocs => [:clobber_docs, :docs]

  end


end



