; Ruby Installer - InnoSetup Script (base)
; This script is used to build Ruby Installers for Windows

; PRE-CHECK
; Verify if both RubyPath and RubyVersion are defined
; by ISCC using /d parameter:
;  iscc rubyinstaller.iss /dRubyVersion=X.Y.Z /dRubyPatch=123 /dRubyPath=sandbox/ruby18_mingw

#if Defined(RubyVersion) == 0
  #error Please provide a RubyVersion definition using /d parameter.
#endif

#if Defined(RubyPatch) == 0
  #error Please provide a RubyPatch levle definition using /d parameter.
#endif

#if Defined(RubyPath) == 0
  #error Please provide the location of the Ruby to be used with RubyPath variable.
#else
  #if FileExists(RubyPath + '\bin\ruby.exe') == 0
    #error No Ruby installation (bin\ruby.exe) found inside defined RubyPath. Please verify.
  #endif
#endif

; Grab MAJOR.MINOR info from RubyVersion (1.8)
#define RubyMajorMinor Copy(RubyVersion, 1, 3)
#define RubyFullVersion RubyVersion + '-p' + RubyPatch

; Build Installer details using above values
#define InstallerName "Ruby " + RubyFullVersion
#define InstallerPublisher "RubyInstaller Project"
#define InstallerHomepage "http://rubyinstaller.org"

; INCLUDE
; Include version specific definitions
#define InstallerSpecificFile "config-" + RubyMajorMinor + ".iss"
#include InstallerSpecificFile

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications!
AppName={#InstallerName}
AppVerName={#InstallerName}
AppPublisher={#InstallerPublisher}
AppPublisherURL={#InstallerHomepage}
AppVersion={#RubyFullVersion}
DefaultGroupName={#InstallerName}
DisableProgramGroupPage=true
LicenseFile=LICENSE.rtf
Compression=lzma/ultra64
SolidCompression=true
AlwaysShowComponentsList=false
DisableReadyPage=true
InternalCompressLevel=ultra64
VersionInfoCompany={#InstallerPublisher}
VersionInfoCopyright=(c) 2009 {#InstallerPublisher}
VersionInfoDescription=Ruby Programming Language for Windows
VersionInfoTextVersion={#RubyFullVersion}
VersionInfoVersion={#RubyVersion}.{#RubyPatch}
UninstallDisplayIcon={app}\bin\ruby.exe

[Languages]
Name: english; MessagesFile: compiler:Default.isl

[Files]
; NOTE: Don't use "Flags: ignoreversion" on any shared system files
Source: ..\..\{#RubyPath}\*; DestDir: {app}; Flags: recursesubdirs createallsubdirs
Source: setrbvars.bat; DestDir: {app}\bin

[Icons]
Name: {group}\Documentation\Getting Started; Filename: http://www.ruby-doc.org/gettingstarted/
Name: {group}\Documentation\Standard Library; Filename: http://www.ruby-doc.org/stdlib/
Name: {group}\Documentation\User's Guide; Filename: http://www.ruby-doc.org/docs/UsersGuide/rg/
Name: {group}\Interactive Ruby; Filename: {app}\bin\irb.bat; IconFilename: {app}\bin\ruby.exe; Flags: createonlyiffileexists
Name: {group}\RubyGems Documentation Server; Filename: {app}\bin\gem.bat; Parameters: server; IconFilename: {app}\bin\ruby.exe; Flags: createonlyiffileexists runminimized
Name: {group}\Start Command Prompt with Ruby; Filename: {sys}\cmd.exe; Parameters: /E:ON /K {app}\bin\setrbvars.bat; WorkingDir: {%HOMEDRIVE}{%HOMEPATH}; IconFilename: {sys}\cmd.exe; Flags: createonlyiffileexists
Name: {group}\{cm:UninstallProgram,{#InstallerName}}; Filename: {uninstallexe}
