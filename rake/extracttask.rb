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
  
  # based on filetypes, extract the files
  case file
    # tar.z, tar.gz, tar.bz2 and tar.lzma contains .tar files inside, use bsdtar to
    # extract the files directly to target directory without the need to first
    # extract to a temporary directory as when using 7za.exe
    when /(^.+\.tar)\.z$/, /(^.+\.tar)\.gz$/, /(^.+\.tar)\.bz2$/, /(^.+\.tar)\.lzma$/
      bsd_tar_extract(target, file)
    when /(^.+)\.tgz$/
      bsd_tar_extract(target, file)
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
end

def seven_zip(target, file)
  puts "** Extracting #{file} into #{target}" if Rake.application.options.trace
  sh "\"#{RubyInstaller::SEVEN_ZIP}\" x -y -o\"#{target}\" \"#{file}\" > NUL"
end

#TODO confirm function returns false upon failing 7-Zip integrity test
def seven_zip_valid?(target)
  puts "** 7-Zip integrity checking '#{target}'" if Rake.application.options.trace
  sh "\"#{RubyInstaller::SEVEN_ZIP}\" t \"#{target}\" > NUL"
end

def seven_zip_get(source, item, target)
  puts "** Extracting '#{item}' from '#{source}' into '#{target}'" if Rake.application.options.trace
  sh "\"#{RubyInstaller::SEVEN_ZIP}\" e \"#{source}\" -o\"#{target}\" \"#{item}\" > NUL"
end

def seven_zip_build(source, target, options={})
  puts "** Building '#{target}' from '#{source}'" if Rake.application.options.trace
  sfx_arg = '-sfx7z.sfx' if options[:sfx]
  sh "\"#{RubyInstaller::SEVEN_ZIP}\" a -mx=9 #{sfx_arg} \"#{target}\" \"#{source}\" > NUL"
end

def bsd_tar_extract(target, file)
  puts "** Extracting #{file} into #{target}" if Rake.application.options.trace
  absolute_file = File.expand_path(file)
  Dir.chdir(target) do
    sh "\"#{RubyInstaller::BSD_TAR}\" -xf \"#{absolute_file}\" > NUL"
  end
end
