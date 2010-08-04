; DevKit InnoSetup Script
; Copyright 2010 Jon Maken
; Created: 07/20/2010 11:27:21 AM
; Revision:
;
; Usage:
;  iscc devkit.iss
;

#include "dk_config.iss"
 
[Setup]
PrivilegesRequired=lowest

Compression=lzma2/ultra64
InternalCompressLevel=ultra64
SolidCompression=true

DisableWelcomePage=true
DisableProgramGroupPage=true
DisableReadyPage=true
AlwaysShowComponentsList=false

LicenseFile=LICENSE.txt
;InfoAfterFile=

[Languages]
Name: en; MessagesFile: compiler:Default.isl

[Files]
Source: ..\..\{#DevKitPath}\*; DestDir: {app}; Flags: recursesubdirs createallsubdirs
