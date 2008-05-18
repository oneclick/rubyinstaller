require 'fileutils'

# extract(+file+, +target+)
def extract(file, target, options = {})
  fail unless File.directory?(target)
  
  # create a temporary folder used to extract files there
  tmpdir = File.join(Dir.tmpdir, "extract_sandbox_#{$$}")
  FileUtils.mkpath(tmpdir)
  
  cmd, options = case file
    when /\.tar\.z$/, /\.tar\.gz$/, /\.tgz$/
      ['bsdtar.exe', 'xzf']
    when /\.tar\.bz2$/
      ['bsdtar.exe', 'jxf']
    when /\.zip$/
      ['unzip.exe', '-qq']
    else
      raise "Unknown file extension! (for file #{file})"
  end
  
  # prepend path to binary
  cmd = "\"#{File.expand_path('sandbox/extract_utils')}/#{cmd}\" #{options} \"#{file}\""

  # extract into temporary directory.
  Dir.chdir(tmpdir) { sh(cmd) }
  
  # now analyze if is just one folder or individuals
  contents = []
  Dir.chdir(tmpdir) { contents = Dir.glob("*") }
  
  # the package was created inside another folder
  # exclude folders packagename-X.Y.Z or packagename-DATE
  if contents.length == 1 and File.directory?(File.join(tmpdir, contents.first)) and contents.first =~ /\-/
    puts "** Using #{contents.first} as source." if Rake.application.options.trace
    to_move = File.join(tmpdir, contents.first)
  else
    to_move = tmpdir
  end
  
  # move the contents back to the target
  Dir.glob("#{to_move}/*").each do |f|
    begin
      puts "** Copy #{f}" if Rake.application.options.trace
      FileUtils.cp_r(f, target)
    rescue Errno::EACCES => e
      # handle the permission denied errors on files
      # Grab the conflicting file from the exception message:
      # Permission denied - path/to/file.ext
      file = e.message.split(' - ').last
      FileUtils.rm_f(file)
      retry
    end
  end
  
  # remove temp folder
  FileUtils.rm_rf(tmpdir)
end
