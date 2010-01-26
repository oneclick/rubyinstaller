== MinGW Ruby Installer: Bootstrapping Recipes

This project attempts to generate a development sandbox that will be used to
compile Ruby and it's components using MinGW tools. Our goal is to offer a 
simplified way to boost your productivity and ease the path for anyone who 
would like to contribute to the Ruby Installer for Windows.

These are a work-in-progress collection of Rake recipes that download, compile
and check MinGW utils required to build Ruby (1.8 and 1.9 at this time) and it's 
dependencies.

It depends on Rake (a Ruby make tool) and you can find most of the recipes for
each component inside recipes/ directory.

Layout and organization explained:

The recipes are distributed in the following layout:

compiler/*.rake: here resides the recipes to download and prepare the compiler
to be used to build the interpreter (MinGW for now).

interpreter/*.rake: the idea is to provide a series of recipes that would allow 
one to build other interpreters besides Matz's Ruby (Rubinius, JRuby, etc).

dependencies/*.rake: this contains the dependencies needed to be downloaded,
compiled and included for the interpreter to work properly. At this time zlib,
rb-readline,  gdbm, iconv, pdcurses, and openssl are included.

packager/*.rake: here we will store the basic recipes to generate installer
packages (using the Innosetup toolset) or any other kind of package.

tools/*.rake: this is where the additional components of the installer are 
located.  Currently, there are recipes for the rubygems package management
system, an RDoc based MS HTML Help file, and the book "The Little Book of Ruby"
courtesy of Huw Collingbourne.

=== Requirements:

At this time you require to have a working Ruby installation (current stable
One-Click installer release is enough).

In case you don't use OCI for this, you need:

- Ruby 1.8.5 at least (mswin32 or mingw32 implementation will work) -- Not cygwin!
- Rake 0.7.3 or greater
- Zlib extension and DLL (zlib1.dll) available in the PATH (could be in system32
or your Ruby bin directory)

Innosetup 5 is required to compile the installer. The InnoSetup QuickStart Pack 
5.3.3 contains all of the required components.

=== Build options:
without specifying any options, 1.8.6 is built.
rake ruby19                      # builds 1.9.1
rake CHECKOUT=1                  # builds 1.8.6 svn latest
rake ruby19 CHECKOUT=1           # builds 1.9.1 svn latest
rake ruby19 CHECKOUT=1 TRUNK=1   # builds 1.9 trunk latest (1.9.2dev).
rake ruby19 LOCAL="c:\myruby"    # builds 1.9 from sources at "c:\myruby"

NOTE: Avoid extracting this project into a PATH with spaces, MSYS has issues
mounting fstab for MinGW.

NOTE: On Vista, run the rake task from an administrator command prompt or "/bin/patch"
will fail during the build.
