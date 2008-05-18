require 'rake'
require 'rake/clean'

# default cleanup
CLOBBER.include("sandbox")
CLOBBER.include("downloads")

# define common tasks
directory "downloads"
directory "sandbox"
