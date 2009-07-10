require 'rubygems'
# require 'rdoc/rdoc'
$LOAD_PATH.unshift(File.join(RubyInstaller::ROOT, '../rdoc_chm/lib'))
require 'rdoc/generator/chm'
require 'erb'
HHC_PATH = "c:/Program Files/HTML Help Workshop/hhc.exe"

namespace(:interpreter) do
  namespace(:ruby18) do

    
    default_opts = ['--line-numbers', '--format=chm', '--debug']
    # ruby_opts    = "-I #{File.join(RubyInstaller::ROOT, '../rdoc_chm/lib')}"  # used for testing rdoc_chm
    
    # rdoc         = File.join(::Config::CONFIG['bindir'], 'rdoc')
    # @cmd         = "ruby #{ruby_opts} #{rdoc} #{default_opts}"
    @target      = File.join(RubyInstaller::ROOT, 'sandbox', 'doc')
    
    @rdocs ={
      'ruby-core' => {
        :file  => File.join(@target, "ruby-core.chm"),
        :title => 'Ruby Core API Reference',
        :filter => Dir[File.join(RubyInstaller::ROOT, RubyInstaller::Ruby18.target, "*.c")].map{|f| File.basename(f) },
      },
      # 'ruby-stdlib' => {
      #   :file  => File.join(@target, "ruby-stdlib.chm"),
      #   :title => 'Ruby Standard Library API Reference',
      #   :filter  => ['./lib', './ext']
      # },
      'readme' => {
        :file  => File.join(@target, "index.html"),
        :title => 'README',
        :filter => ['README'],
        :opts   => ['--main=README']
      }
    }
    
    @rdocs.each do |name, chm|
    
      file chm[:file]
          
      task name => chm[:file] do
        op = File.join(@target, name)
        
        #create core documentation          
        cd File.join(RubyInstaller::ROOT, RubyInstaller::Ruby18.target) do
          args = default_opts + (chm[:opts] || []) + ['--title',chm[:title].inspect,'--op',op] + chm[:filter]
          
          rdoc = RDoc::RDoc.new
          rdoc.document(args)
        end
        
        cp File.join(op, File.basename(chm[:file])), @target
      end
      
      task :docs => name
    end

    task :meta => @rdocs.keys do
      @chm = OpenStruct.new
      @chm.title = 'Ruby 1.8.6 Help file'
      @chm.file  = 'ruby186'
      
      Dir[File.join(RubyInstaller::ROOT, 'resources', 'chm', '*.rhtml')].each{|f| cp f, @target }
      cd @target do
        @chm.files = Dir['*.html'].map{|f| File.basename(f) }
        @chm.merge_files = Dir['*.chm'].map{|f| File.basename(f) }
        Dir['*.rhtml'].each do |rhtml_file| 
          # p rhtml_file
          File.open(File.basename(rhtml_file, '.rhtml'),'w+') do |output_file| 
            output = ERB.new(File.read(rhtml_file)).result(binding)
            output_file.write(output)
          end
        end

        Dir['*.hhp'].each{|hhp| system(HHC_PATH, hhp) }
      end
      
    end
    
    task :docs => :meta

    task :clobber_docs do
      rm_rf 'sandbox/doc'
    end
  end
end

# namespace :meta_chm do

#   task :docs
  
#   task :clobber_docs

# end

task :docs   => ['interpreter:ruby18:docs']
task :clobber_docs   => ['interpreter:ruby18:clobber_docs']
task :redocs => [:clobber_docs, :docs]