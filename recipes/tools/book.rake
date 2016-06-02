require 'rake'
require 'rake/clean'

namespace(:book) do
  package = RubyInstaller::Book
  directory package.target
  CLEAN.include(package.target)

  # Put files for the :download task
  dt = checkpoint(:book, :download)
  package.files.each do |f|
    file_source = "#{package.url}/#{f}"
    file_target = "#{RubyInstaller::DOWNLOADS}/#{f}"
    download file_target => file_source

    # depend on downloads directory
    file file_target => RubyInstaller::DOWNLOADS

    # download task need these files as pre-requisites
    dt.enhance [file_target]
  end
  task :download => dt

  # Prepare the :sandbox, it requires the :download task
  et = checkpoint(:book, :extract) do
    dt.prerequisites.each { |f|
      extract(f, package.target)
    }
  end
  task :extract => [:extract_utils, :download, package.target, et]
end

desc "Download and extract The Book of Ruby"
task :book => [
  'book:download',
  'book:extract'
]
