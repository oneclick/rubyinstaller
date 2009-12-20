== MinGW RubyInstaller: Bootstrapping Build Recipes

This project attempts to generate a development sandbox that can be used to
compile Ruby and it's components using the freely available MinGW toolchain.
Our goal is to offer a simplified way to boost your productivity when building
Ruby from source code on your Windows system, and ease the path for anyone
wishing to contribute to the RubyInstaller for Windows project.

This project is a work-in-progress collection of Rake build recipes that download
and verify the MinGW utilities required to compile and build a Ruby interpreter
(MRI 1.8 and 1.9 at this time) and it's core components and dependencies.

=== 7 Second Quick Start:

Ensure you are connected to the Internet, open a Command Prompt, 'cd' to the
project root directory, and type one of:

rake          # builds MRI 1.8.6
rake ruby19   # builds MRI 1.9.1

=== Project Directory Organization:

The Rake build recipes are distributed inside the project's recipes/ directory
using the following sub-directory structure:

compiler/*.rake: the recipes to download and prepare the native code compiler
(MinGW for now) that will be used to build the Ruby interpreter.

dependencies/*.rake: the recipes contains the dependencies needed to be downloaded,
compiled and included for the interpreter to work properly. At this time zlib,
rb-readline, gdbm, iconv, pdcurses, and openssl are included.

extract_utils/*.rake: the low-level archive extraction utility recipes used by
other core build recipes.

interpreter/*.rake: the recipes to build the Matz's Ruby Interpreter and, in 
the future, other Ruby interpreters (Rubinius, JRuby, etc).

packager/*.rake: the recipes use to generate Windows installer packages
(currently the Innosetup toolset) and other kinds of packages.

tools/*.rake: the recipes for the additional components of the installer.
Currently, recipes exist for the RubyGems package management system, the creation
of RDoc-based MS HTML Help (CHM) files, and the book "The Little Book of Ruby"
courtesy of Huw Collingbourne.

=== Requirements:

At this time you need to have a working Ruby installation (the current stable
One-Click Installer release is enough).

In case you don't have the OCI installed, you will need:

- Ruby 1.8.5 or greater (mswin32 or mingw32 implementation will work) -- Not cygwin!
- Rake 0.7.3 or greater
- Zlib extension and DLL (zlib1.dll) available in the PATH (could be in system32
or your Ruby bin directory)

Innosetup 5 is required to compile and build the Windows installer. The InnoSetup
QuickStart Pack 5.3.3+ contains all of the required components.

=== Build Task Examples:

rake                             # builds 1.8.6 [default build task]
rake ruby18                      # builds 1.8.6
rake ruby19                      # builds 1.9.1
rake CHECKOUT=1                  # builds 1.8.6 svn latest
rake ruby19 CHECKOUT=1           # builds 1.9.1 svn latest
rake ruby19 CHECKOUT=1 TRUNK=1   # builds 1.9 trunk latest (1.9.2dev).

NOTE: Avoid extracting this project into a PATH containing spaces as the MSYS
environment has issues correctly mounting /etc/fstab entries for MinGW.

NOTE: On Vista or Windows 7, run the rake task from an administrator command
prompt or "/bin/patch" will fail during the build.
