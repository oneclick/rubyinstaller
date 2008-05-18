#
# This Rake Task is a striped down version of Buildr download task
# I took the code from http://rubyforge.org/projects/buildr
#
# I've striped down dependencies on Net::SSH and Facets to
# stay as simple as possible.
#
# Original code from Assaf Arkin, released under Apache License
# (http://buildr.rubyforge.org/license.html)
#

require 'rake'
require 'tempfile'

require File.join(File.dirname(__FILE__), 'contrib', 'uri_ext')

def download(args)
  args = URI.parse(args) if args.is_a?(String)
  
  options = {
    :progress => true,
    :verbose => Rake.application.options.trace
  }
  
  # Given only a download URL, download into a temporary file.
  # You can infer the file from task name.
  if URI === args
    temp = Tempfile.open(File.basename(args.to_s))
    file_create(temp.path) do |task|
      # Since temporary file exists, force a download.
      class << task ; def needed?() ; true ; end ; end
      task.sources << args
      task.enhance { args.download(temp, options) }
    end
  else
    # Download to a file task instead
    fail unless args.keys.size == 1
    uri = URI.parse(args.values.first.to_s)
    file_create(args.keys.first) do |task|
      task.sources << uri
      task.enhance { uri.download(task.name, options) }
    end
  end
end
