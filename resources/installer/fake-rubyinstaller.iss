; Fake Ruby Installer - InnoSetup Script
; This script is used to build fake RubyInstallers for Windows for testing purposes
; Copyright (c) 2009-2010 Jon Maken
; Revision: 03/06/2010 5:57:10 PM
; License: MIT

; PRE-CHECK
; Verify that RubyPath, RubyVersion, and RubyPath are defined by ISCC using
; /d command line arguments.
;
;  Usage example:
;  iscc rubyinstaller-fake.iss /dRubyVersion=X.Y.Z /dRubyPatch=123 /dRubyPath=sandbox/fake
;                              [/dInstVersion=26-OCT-2009]

#if Defined(RubyVersion) == 0
  #error Please provide a RubyVersion definition using a /d parameter.
#endif

#if Defined(RubyPatch) == 0
  #error Please provide a RubyPatch level definition using a /d parameter.
#endif

#if Defined(RubyPath) == 0
  #error Please provide a RubyPath value to the Ruby files using a /d parameter.
#endif

#if Defined(InstVersion) == 0
  #define InstVersion GetDateTimeString('dd-mmm-yy"T"hhnn', '', '')
#endif

; Grab MAJOR.MINOR info from RubyVersion (1.8)
#define RubyMajorMinor Copy(RubyVersion, 1, 3)
#define RubyFullVersion RubyVersion + '-p' + RubyPatch

; Build Installer details using above values
#define InstallerName "FakeRuby " + RubyFullVersion
#define InstallerPublisher "RubyInstaller Project"
#define InstallerHomepage "http://rubyinstaller.org"
#define DefaultInstallDirBase "FakeRuby" + Copy(RubyVersion, 1, 1) + \
                              Copy(RubyVersion, 3, 1) + Copy(RubyVersion, 5, 1)

#define CurrentYear GetDateTimeString('yyyy', '', '')

#define InstallerAppId "FakeRubyInstaller " + RubyVersion
#define RubyInstallerBaseId "FakeRubyInstaller"

[Setup]
AppId={#InstallerAppId}
DefaultDirName={sd}\{#DefaultInstallDirBase}

AppName={#InstallerName}
AppVerName={#InstallerName}
AppPublisher={#InstallerPublisher}
AppPublisherURL={#InstallerHomepage}
AppVersion={#RubyFullVersion}
DefaultGroupName={#InstallerName}
DisableProgramGroupPage=true
LicenseFile=LICENSE.txt
Compression=lzma/ultra64
SolidCompression=true
AlwaysShowComponentsList=false
DisableReadyPage=true
InternalCompressLevel=ultra64
VersionInfoCompany={#InstallerPublisher}
VersionInfoCopyright=(c) {#CurrentYear} {#InstallerPublisher}
VersionInfoDescription=Ruby Programming Language for Windows
VersionInfoTextVersion={#RubyFullVersion}
VersionInfoVersion={#RubyVersion}.{#RubyPatch}
UninstallDisplayIcon={app}\bin\ruby.exe
WizardImageFile={#SourcePath}\images\fake.bmp
WizardSmallImageFile={#SourcePath}\images\wizard-logo.bmp
PrivilegesRequired=lowest
ChangesAssociations=yes
ChangesEnvironment=yes
OutputBaseFilename=FakeRubyInstaller_{#RubyFullVersion}_{#InstVersion}
SetupLogging=true

[Languages]
Name: english; MessagesFile: compiler:Default.isl

[Messages]
WelcomeLabel1=Welcome to the [name] Installer
WelcomeLabel2=This will install [name/ver] on your computer. Please close all other applications before continuing.
WizardLicense={#InstallerName} License Agreement
LicenseLabel=
LicenseLabel3=Please read the following License Agreement and accept the terms before continuing the installation.
LicenseAccepted=I &accept the License
LicenseNotAccepted=I &decline the License
WizardSelectDir=Installation Destination and Optional Tasks
SelectDirDesc=
SelectDirBrowseLabel=To continue, click Next, or to select a different folder, click Browse.
DiskSpaceMBLabel=Required free disk space: ~[mb] MB

[Files]
; NOTE: Don't use "Flags: ignoreversion" on any shared system files
Source: ..\..\{#RubyPath}\*; DestDir: {app}; Flags: recursesubdirs createallsubdirs
Source: ..\..\sandbox\book\bookofruby.pdf; DestDir: {app}\doc
Source: setrbvars.bat; DestDir: {app}\bin

[Registry]
; .rb file for admin
Root: HKLM; Subkey: Software\Classes\.rb; ValueType: string; ValueName: ; ValueData: "RubyFile"; Flags: uninsdeletevalue uninsdeletekeyifempty; Check: IsAdmin and IsAssociated;
Root: HKLM; Subkey: Software\Classes\RubyFile; ValueType: string; ValueName: ; ValueData: "Ruby File"; Flags: uninsdeletekey; Check: IsAdmin and IsAssociated;
Root: HKLM; Subkey: Software\Classes\RubyFile\DefaultIcon; ValueType: string; ValueName: ; ValueData: "{app}\bin\RUBY.EXE,0"; Check: IsAdmin and IsAssociated;
Root: HKLM; Subkey: Software\Classes\RubyFile\shell\open\command; ValueType: string; ValueName: ; ValueData: """{app}\bin\ruby.exe"" ""%1"" %*"; Check: IsAdmin and IsAssociated;

; .rbw file for admin
Root: HKLM; Subkey: Software\Classes\.rbw; ValueType: string; ValueName: ; ValueData: "RubyWFile"; Flags: uninsdeletevalue uninsdeletekeyifempty; Check: IsAdmin and IsAssociated;
Root: HKLM; Subkey: Software\Classes\RubyWFile; ValueType: string; ValueName: ; ValueData: "RubyW File"; Flags: uninsdeletekey; Check: IsAdmin and IsAssociated;
Root: HKLM; Subkey: Software\Classes\RubyWFile\DefaultIcon; ValueType: string; ValueName: ; ValueData: "{app}\bin\RUBYW.EXE,0"; Check: IsAdmin and IsAssociated;
Root: HKLM; Subkey: Software\Classes\RubyWFile\shell\open\command; ValueType: string; ValueName: ; ValueData: """{app}\bin\rubyw.exe"" ""%1"" %*"; Check: IsAdmin and IsAssociated;

; .rb file for non-admin
Root: HKCU; Subkey: Software\Classes\.rb; ValueType: string; ValueName: ; ValueData: "RubyFile"; Flags: uninsdeletevalue uninsdeletekeyifempty; Check: IsNotAdmin and IsAssociated;
Root: HKCU; Subkey: Software\Classes\RubyFile; ValueType: string; ValueName: ; ValueData: "Ruby File"; Flags: uninsdeletekey; Check: IsNotAdmin and IsAssociated;
Root: HKCU; Subkey: Software\Classes\RubyFile\DefaultIcon; ValueType: string; ValueName: ; ValueData: "{app}\bin\RUBY.EXE,0"; Check: IsNotAdmin and IsAssociated;
Root: HKCU; Subkey: Software\Classes\RubyFile\shell\open\command; ValueType: string; ValueName: ; ValueData: """{app}\bin\ruby.exe"" ""%1"" %*"; Check: IsNotAdmin and IsAssociated;

; .rbw file for non-admin
Root: HKCU; Subkey: Software\Classes\.rbw; ValueType: string; ValueName: ; ValueData: "RubyWFile"; Flags: uninsdeletevalue uninsdeletekeyifempty; Check: IsNotAdmin and IsAssociated;
Root: HKCU; Subkey: Software\Classes\RubyWFile; ValueType: string; ValueName: ; ValueData: "RubyW File"; Flags: uninsdeletekey; Check: IsNotAdmin and IsAssociated;
Root: HKCU; Subkey: Software\Classes\RubyWFile\DefaultIcon; ValueType: string; ValueName: ; ValueData: "{app}\bin\RUBYW.EXE,0"; Check: IsNotAdmin and IsAssociated;
Root: HKCU; Subkey: Software\Classes\RubyWFile\shell\open\command; ValueType: string; ValueName: ; ValueData: """{app}\bin\rubyw.exe"" ""%1"" %*"; Check: IsNotAdmin and IsAssociated;

; RubyInstaller identification for admin
Root: HKLM; Subkey: Software\RubyInstaller; ValueType: string; ValueName: ; ValueData: ; Flags: uninsdeletevalue uninsdeletekeyifempty; Check: IsAdmin
Root: HKLM; Subkey: Software\RubyInstaller\{#RubyInstallerBaseId}; ValueType: string; ValueName: ; ValueData: ; Flags: uninsdeletevalue uninsdeletekeyifempty; Check: IsAdmin
Root: HKLM; Subkey: Software\RubyInstaller\{#RubyInstallerBaseId}\{#RubyVersion}; ValueType: string; ValueName: ; ValueData: ; Flags: uninsdeletekey; Check: IsAdmin
Root: HKLM; Subkey: Software\RubyInstaller\{#RubyInstallerBaseId}\{#RubyVersion}; ValueType: string; ValueName: InstallLocation ; ValueData: {app}; Check: IsAdmin
Root: HKLM; Subkey: Software\RubyInstaller\{#RubyInstallerBaseId}\{#RubyVersion}; ValueType: string; ValueName: InstallDate ; ValueData: {code:GetInstallDate}; Check: IsAdmin
Root: HKLM; Subkey: Software\RubyInstaller\{#RubyInstallerBaseId}\{#RubyVersion}; ValueType: string; ValueName: PatchLevel ; ValueData: {#RubyPatch}; Check: IsAdmin
Root: HKLM; Subkey: Software\RubyInstaller\{#RubyInstallerBaseId}\{#RubyVersion}; ValueType: string; ValueName: BuildPlatform ; ValueData: i386-mingw32; Check: IsAdmin

; RubyInstaller identification for non-admin
Root: HKCU; Subkey: Software\RubyInstaller; ValueType: string; ValueName: ; ValueData: ; Flags: uninsdeletevalue uninsdeletekeyifempty; Check: IsNotAdmin
Root: HKCU; Subkey: Software\RubyInstaller\{#RubyInstallerBaseId}; ValueType: string; ValueName: ; ValueData: ; Flags: uninsdeletevalue uninsdeletekeyifempty; Check: IsNotAdmin
Root: HKCU; Subkey: Software\RubyInstaller\{#RubyInstallerBaseId}\{#RubyVersion}; ValueType: string; ValueName: ; ValueData: ; Flags: uninsdeletekey; Check: IsNotAdmin
Root: HKCU; Subkey: Software\RubyInstaller\{#RubyInstallerBaseId}\{#RubyVersion}; ValueType: string; ValueName: InstallLocation ; ValueData: {app}; Check: IsNotAdmin
Root: HKCU; Subkey: Software\RubyInstaller\{#RubyInstallerBaseId}\{#RubyVersion}; ValueType: string; ValueName: InstallDate ; ValueData: {code:GetInstallDate}; Check: IsNotAdmin
Root: HKCU; Subkey: Software\RubyInstaller\{#RubyInstallerBaseId}\{#RubyVersion}; ValueType: string; ValueName: PatchLevel ; ValueData: {#RubyPatch}; Check: IsNotAdmin
Root: HKCU; Subkey: Software\RubyInstaller\{#RubyInstallerBaseId}\{#RubyVersion}; ValueType: string; ValueName: BuildPlatform ; ValueData: i386-mingw32; Check: IsNotAdmin

[Icons]
Name: {group}\Documentation\The Book of Ruby; Filename: {app}\doc\bookofruby.pdf; Flags: createonlyiffileexists
Name: {group}\Interactive Ruby; Filename: {app}\bin\irb.bat; IconFilename: {app}\bin\ruby.exe; Flags: createonlyiffileexists
Name: {group}\RubyGems Documentation Server; Filename: {app}\bin\gem.bat; Parameters: server; IconFilename: {app}\bin\ruby.exe; Flags: createonlyiffileexists runminimized
Name: {group}\Start Command Prompt with Ruby; Filename: {sys}\cmd.exe; Parameters: /E:ON /K {app}\bin\setrbvars.bat; WorkingDir: {%HOMEDRIVE}{%HOMEPATH}; IconFilename: {sys}\cmd.exe; Flags: createonlyiffileexists
Name: {group}\{cm:UninstallProgram,{#InstallerName}}; Filename: {uninstallexe}

[Code]
#include "util.iss"
#include "ri_gui.iss"

function GetInstallDate(Param: String): String;
begin
  Result := GetDateTimeString('yyyymmdd', #0 , #0);
end;

procedure CurStepChanged(const CurStep: TSetupStep);
begin

  // TODO move into ssPostInstall just after install completes?
  if CurStep = ssInstall then
  begin
    if UsingWinNT then
    begin
      Log(Format('Selected Tasks - Path: %d, Associate: %d', [PathChkBox.State, PathExtChkBox.State]));

      if IsModifyPath then
        ModifyPath([ExpandConstant('{app}') + '\bin']);

      if IsAssociated then
        ModifyFileExts(['.rb', '.rbw']);

    end else
      MsgBox('Looks like you''ve got on older, unsupported Windows version.' #13 +
             'Proceeding with a reduced feature set installation.',
             mbInformation, MB_OK);
  end;
end;

procedure RegisterPreviousData(PreviousDataKey: Integer);
begin
  {* store install choices so we can use during uninstall *}
  if IsModifyPath then
    SetPreviousData(PreviousDataKey, 'PathModified', 'yes');
  if IsAssociated then
    SetPreviousData(PreviousDataKey, 'FilesAssociated', 'yes');

  SetPreviousData(PreviousDataKey, 'RubyInstallerId', ExpandConstant('{#RubyInstallerBaseId}\{#RubyVersion}'));
end;

procedure CurUninstallStepChanged(const CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    if UsingWinNT then
    begin
      if GetPreviousData('PathModified', 'no') = 'yes' then
        ModifyPath([ExpandConstant('{app}') + '\bin']);

      if GetPreviousData('FilesAssociated', 'no') = 'yes' then
        ModifyFileExts(['.rb', '.rbw']);

    end;
  end;
end;
