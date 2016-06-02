require 'rake'
require 'rake/clean'

# default cleanup
CLOBBER.include("sandbox")
CLOBBER.include(RubyInstaller::DOWNLOADS)

# define common tasks
directory (RubyInstaller::DOWNLOADS)
directory "sandbox"
