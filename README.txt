== MinGW One-Click Installer: Bootstrapping Recipes

This project attempts to generate a development sandbox that will be used to
compile Ruby and it's components using MinGW tools. Our goal is to offer a 
simplified way to boost your productivity and ease the path for anyone who 
would like to contribute to the One-Click Ruby Installer for Windows.

These are a work-in-progress collection of Rake recipes that download, compile
and check MinGW utils required to build Ruby 1.8 (at this time) and it's depen-
dencies.

It depends on Rake (a Ruby make tool) and you can find most of the recipes for
each component inside recipes/ directory.

Layout and organization explained:

The recipes are distributed in the following layout:

compiler/*.rake: here resides the recipes to download and prepare the compiler
to be used to build the interpreter (MinGW for now).

interpreter/*.rake: the idea is to provide a series of recipes that would allow 
one to build other interpreters besides Matz's Ruby (Rubinius, JRuby, etc).

dependencies/*.rake: this contains the dependencies needed to be downloaded,
compiled and included for the interpreter to work properly. At this time only
readline, zlib and openssl are included.

installer/*.rake: here we will store the basic recipes to generate MSI packages
(using the WiX toolset) or any other kind of package.

=== Requirements:

At this time you require to have a working Ruby installation (current stable
One-Click release is enough).

In case you don't use OCI for this, you need:

- Ruby 1.8.5 at least (mswin32 or mingw32 implementation will work) -- Not cygwin!
- Rake 0.7.3 or greater
- Zlib extension and DLL (zlib1.dll) available in the PATH (could be in system32
or your RUby bin directory)

NOTE: Avoid extracting this project into a PATH with spaces, MSYS have issues
mounting fstab for MinGW.

To generate the Microsoft Windows Installer (MSI), you require have dotNET 2.0
for WiX toolset to work and dotNET 3.5 for Paraffin utility.

NOTE: On Vista, run the rake task from an administrator command prompt or "/bin/patch"
will fail during the build.
