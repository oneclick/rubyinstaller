; Ruby Installer - InnoSetup Script (base)

; This script is used to build Ruby Installers for Windows

; Define common names to be used in the script
#define RubyVersion "1.8.6-p368"
#define InstallerTarget "Ruby"

; Build Installer details using above values
#define InstallerName "Ruby " + RubyVersion
#define InstallerPublisher "RubyInstaller Project"
#define InstallerHomepage "http://rubyinstaller.org"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{190D87C5-B8F9-4E3D-A872-01B379F1752F}
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
Compression=lzma
SolidCompression=true
VersionInfoCompany={#InstallerPublisher}
VersionInfoTextVersion={#InstallerName}
VersionInfoCopyright=(c) 2009 {#InstallerPublisher}
DisableFinishedPage=true
AlwaysShowComponentsList=false
FlatComponentsList=false
DisableReadyPage=true

[Languages]
Name: english; MessagesFile: compiler:Default.isl

[Files]
Source: ..\..\sandbox\ruby18_mingw\*; DestDir: {app}; Flags: recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: {group}\{cm:UninstallProgram,{#InstallerName}}; Filename: {uninstallexe}
