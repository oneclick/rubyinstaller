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
#define RubyFullVersion RubyVersion + 'p' + RubyPatch

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
AppSupportURL={#InstallerHomepage}
AppUpdatesURL={#InstallerHomepage}
DefaultGroupName={#InstallerName}
DisableProgramGroupPage=true
LicenseFile=LICENSE.rtf
Compression=lzma/ultra64
SolidCompression=true
VersionInfoCompany={#InstallerPublisher}
VersionInfoTextVersion={#RubyFullVersion}
VersionInfoCopyright=(c) 2009 {#InstallerPublisher}
DisableFinishedPage=true
AlwaysShowComponentsList=false
FlatComponentsList=false
DisableReadyPage=true
InternalCompressLevel=ultra64

[Languages]
Name: english; MessagesFile: compiler:Default.isl

[Files]
; NOTE: Don't use "Flags: ignoreversion" on any shared system files
Source: ..\..\{#RubyPath}\*; DestDir: {app}; Flags: recursesubdirs createallsubdirs

[Icons]
Name: {group}\{cm:UninstallProgram,{#InstallerName}}; Filename: {uninstallexe}
