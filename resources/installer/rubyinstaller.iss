; Ruby Installer - InnoSetup Script (base)
; This script is used to build Ruby Installers for Windows

; PRE-CHECK
; Verify if both RubyPath and RubyVersion are defined
; by ISCC using /d parameter:
;  iscc rubyinstaller.iss /dRubyVersion=X.Y.Z /dRubyPath=sandbox/ruby18_mingw

#if Defined(RubyVersion) == 0
  #error Please provide a RubyVersion definition using /d parameter.
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

; DEFAULTS
; Define the default target directory where Ruby will be installed
#define InstallerTarget "Ruby"

; Build Installer details using above values
#define InstallerName "Ruby " + RubyVersion
#define InstallerPublisher "RubyInstaller Project"
#define InstallerHomepage "http://rubyinstaller.org"

; INCLUDE
; Include version specific definitions
#define InstallerSpecificFile "config-" + RubyMajorMinor + ".iss"
#if FileExists(InstallerSpecificFile)
  #include InstallerSpecificFile
#endif
#undef InstallerSpecificFile

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications!
AppName={#InstallerName}
AppVerName={#InstallerName}
AppPublisher={#InstallerPublisher}
AppPublisherURL={#InstallerHomepage}
AppSupportURL={#InstallerHomepage}
AppUpdatesURL={#InstallerHomepage}
DefaultDirName={sd}\{#InstallerTarget}
DefaultGroupName={#InstallerName}
DisableProgramGroupPage=true
LicenseFile=LICENSE.rtf
OutputDir={#SourcePath}\..\..\pkg
OutputBaseFilename=rubyinstaller-{#RubyVersion}
Compression=lzma/ultra64
SolidCompression=true
VersionInfoCompany={#InstallerPublisher}
VersionInfoTextVersion={#InstallerName}
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
