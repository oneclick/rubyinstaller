#RubyInstaller

This project, licensed under the 3-clause Modified BSD License, attempts to
generate a development sandbox that can be used to compile Ruby and it's
components using the freely available MinGW toolchain. Our goal is to offer a
simplified way to boost your productivity when building Ruby from source code
on your Windows system, and ease the path for anyone wishing to contribute to
the RubyInstaller for Windows project.

This project is a work-in-progress collection of Rake build recipes that download
and verify the MinGW utilities required to compile and build a Ruby interpreter
and it's core components and dependencies.

The recipes also build a DevKit package that, when combined with a RubyInstaller
installation, enables Windows users to easily build and use many of the native
C-based RubyGems extensions that may not yet have a binary RubyGem. The DevKit
(available as a Windows Installer and normal 7-Zip and self-extracting archives)
provides an easy-to-install compiler and build system, and convenient setup helper
scripts.

##7-Second Quick Start

Ensure you are connected to the Internet, open a Command Prompt, `cd` to the
project root directory, and type one of:

    rake          # builds MRI 1.8.7
    rake ruby19   # builds MRI 1.9.2
    rake ruby20   # builds MRI 2.0.0
    rake ruby21   # builds MRI 2.1.x

Please note that for `ruby20` and `ruby21`, you need to use a different DevKit version
than the default one.  
At this time, `mingw64-32-4.7.2` and `mingw64-64-4.7.2` are used, e.g:

    rake ruby21 DKVER=mingw64-32-4.7.2

##Project Directory Organization

The Rake build recipes are distributed inside the project's recipes/ directory
using the following sub-directory structure:

- `compiler/*.rake`: the recipes to download and prepare the native code compiler
(MinGW for now) that will be used to build the Ruby interpreter.

- `dependencies/*.rake`: the recipes contains the dependencies needed to be downloaded,
compiled and included for the interpreter to work properly. At this time zlib,
rb-readline, gdbm, iconv, pdcurses, and openssl are included.

- `devkit/*.rake`: the recipes for downloading the MSYS/MinGW/TDM artifacts needed
to build native C-based RubyGem extensions. The recipes conveniently package the
artifacts into a Windows Installer, and normal 7-Zip and self-extracting archives.

- `extract_utils/*.rake`: the low-level archive extraction utility recipes used by
other core build recipes.

- `interpreter/*.rake`: the recipes to build the Matz's Ruby Interpreter and, in
the future, other Ruby interpreters (Rubinius, JRuby, etc).

- `packager/*.rake`: the recipes use to generate Windows installer packages
(currently the Innosetup toolset) and other kinds of packages.

- `tools/*.rake`: the recipes for the additional components of the installer.
Currently, recipes exist for the RubyGems package management system, the creation
of RDoc-based MS HTML Help (CHM) files, and the book "The Little Book of Ruby"
courtesy of Huw Collingbourne.

The recipe configuration files are distributed in the `config/` sub-directory of
the project's root directory. Configuration files for different DevKit compilers
are distributed in the `config/compilers/` sub-directory.

To override the default configuration, create an `override/build_config.rb` file
in the project's root directory. See the default `config/ruby_installer.rb` and
`config/devkit.rb` configuration files for values that can be overridden.

##Requirements

At this time you need to have a working Ruby installation (the current stable
One-Click Installer release is enough).

In case you don't have the OCI installed, you will need:

- Ruby 1.8.5 or greater (mswin32 or mingw32 implementation will work) -- **Not cygwin!**
- Rake 0.7.3 or greater
- Zlib extension and DLL (zlib1.dll) available in the PATH (could be in system32
or your Ruby bin directory)

Innosetup 5.4.2 is required to compile and build the Windows installer.

##Build Task Examples

    rake                             # builds 1.8.7 [default build task]
    rake ruby18                      # builds 1.8.7
    rake ruby18 COMPAT=1             # builds 1.8.6
    rake ruby19                      # builds 1.9.2
    rake ruby19 COMPAT=1             # builds 1.9.1
    rake ruby20                      # builds 2.0.0
    rake ruby21                      # builds 2.1.x
    rake CHECKOUT=1                  # builds 1.8.7 svn latest (branch ruby_1_8_7)
    rake LOCAL="c:\myruby18"         # builds 1.8.x from sources at "c:\myruby18"
    rake ruby19 CHECKOUT=1           # builds 1.9.1 svn latest
    rake ruby19 CHECKOUT=1 TRUNK=1   # builds 1.9 trunk latest (1.9.3)
    rake ruby19 LOCAL="c:\myruby"    # builds 1.9 from sources at "c:\myruby"
    rake ruby19 MAKE_OPT=-j8         # builds 1.9 by make -j8 (parallel build)

You can combine `COMPAT` and `CHECKOUT` to build Ruby 1.8.6 directly from the
Subversion repository.

###DevKit Build Task Examples:

    rake devkit                      # builds Installer (TDM 4.5.2)
    rake devkit DKVER=tdm-32-4.6.1   # builds Installer (TDM 32-bit 4.6.1)
    rake devkit 7Z=1                 # builds Installer and 7-Zip archive
    rake devkit SFX=1                # builds Installer and self-extracting archive

While the only officially supported DevKit's are the versions available for
download at http://rubyinstaller.org/downloads both the RubyInstaller and
DevKit recipes are flexible enough to allow one to use any one of the compiler
toolchains configured in the `config/compilers/` subdirectory. To list the
available DevKit versions and current default, invoke `rake devkit:ls`.

To use or build a specific compiler toolchain, pass rake the appropriate
`DKVER=<vendor>-<bits>-<version>` command line value as part of your rake task
invocation. For example:

    rake devkit sfx=1 dkver=llvm-32-2.8
    rake ruby19 dkver=mingw-32-4.6.1

If you built a custom DevKit as in the first example, look in the `pkg/`
subdirectory for your DevKit artifact.

###DevKit Compiler Toolchains

    Compiler     DKVER Values

    tdm          tdm-32-4.7.1, tdm-32-4.6.1, tdm-64-4.7.1, tdm-64-4.6.1, tdm-32-4.5.2 (*)
    mingw        mingw-32-4.6.2, mingw-32-3.4.5
    mingw64      mingw64-32-4.7.2, mingw64-64-4.7.2
    mingwbuilds  mingwbuilds-32-4.7.3, mingwbuilds-64-4.7.3

(*) = default build toolchain

##Known Issues

* Avoid running this project in a PATH containing spaces as the MSYS
  environment has issues correctly mounting /etc/fstab entries for MinGW.
