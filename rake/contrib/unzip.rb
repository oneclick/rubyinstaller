$: << File.dirname(__FILE__)
require 'zip/zip'

module Zip
  def self.fake_unzip(zipfilename, regexp, target_dir)
    Zip::ZipFile.open(zipfilename) do |zipfile|
      Zip::ZipFile.foreach(zipfilename) do |entry|
        if regexp =~ entry.name
          zipfile.extract(entry, File.join(target_dir, File.basename(entry.name))) { true }
        end
      end
    end
  end
end