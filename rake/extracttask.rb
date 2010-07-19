require 'tmpdir'
require 'fileutils'

def mv_r(src, dest, options = {})
  if File.directory? src
    d = File.directory?(dest) ? File.join(dest, File.basename(src)) : dest
    if File.directory? d
      Dir.glob(File.join(src, '*')).each do |s|
        mv_r(s, d, options)
      end
    else
      FileUtils.mv(src, dest, options)
    end
  else
    FileUtils.mv(src, dest, options)
  end
end

def extract(file, target, options = {})
  fail unless File.directory?(target)
  
  # create a temporary folder used to extract files there
  tmpdir = File.expand_path(File.join(Dir.tmpdir, "extract_sandbox_#{$$}"))
  FileUtils.mkpath(tmpdir) unless File.exist?(tmpdir)

  # based on filetypes, extract the intermediate file into the temporary folder
  case file
    # tar.z, tar.gz and tar.bz2 contains .tar files inside, extract into 
    # temp first
    when /(^.+\.tar)\.z$/, /(^.+\.tar)\.gz$/, /(^.+\.tar)\.bz2$/, /(^.+\.tar)\.lzma$/
      seven_zip tmpdir, file
      seven_zip target, File.join(tmpdir, File.basename($1))
    when /(^.+)\.tgz$/
      seven_zip tmpdir, file
      seven_zip target, File.join(tmpdir, "#{File.basename($1)}.tar")
    when /(^.+\.zip$)/
      seven_zip(target, $1)
    else
      raise "Unknown file extension! (for file #{file})"
  end

  # after extraction, lookup for a folder that contains '-' (version number or datestamp)
  folders_in_target = []
  Dir.chdir(target) { folders_in_target = Dir.glob('*') }

  # the package was created inside another folder
  # exclude folders packagename-X.Y.Z or packagename-DATE
  # move all the folders within that into target directly.
  folders_in_target.each do |folder|
    next unless File.directory?(File.join(target, folder)) && folder =~ /\-/

    # take the folder contents out!, now!
    contents = []
    Dir.chdir(File.join(target, folder)) { contents = Dir.glob('*') }

    contents.each do |c|
      puts "** Moving out #{c} from #{folder} and drop into #{target}" if Rake.application.options.trace
      mv_r File.join(target, folder, c), target
    end
    
    # remove the now empty folder
    puts "** Removing #{folder}" if Rake.application.options.trace
    FileUtils.rm_rf File.join(target, folder)
  end

  # remove the temporary directory
  puts "** Removing #{tmpdir}" if Rake.application.options.trace
  FileUtils.rm_rf tmpdir
end

def seven_zip(target, file)
  puts "** Extracting #{file} into #{target}" if Rake.application.options.trace
  sh "\"#{File.expand_path(File.join('sandbox/extract_utils', '7za.exe'))}\" x -y -o\"#{target}\" \"#{file}\" > NUL"
end

#TODO confirm function returns false upon failing 7-Zip integrity test
def seven_zip_valid?(target)
  puts "** 7-Zip integrity checking '#{target}'" if Rake.application.options.trace
  sh "\"#{File.expand_path(File.join('sandbox/extract_utils', '7za.exe'))}\" t \"#{target}\" > NUL"
end

def seven_zip_build(source, target)
  puts "** Building 7-Zip archive from '#{source}'" if Rake.application.options.trace
  sh "\"#{File.expand_path(File.join('sandbox/extract_utils', '7za.exe'))}\" a \"#{target}\" \"#{source}\"> NUL"
end
