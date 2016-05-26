; RubyInstaller Tcl/Tk extension InnoSetup support
; Copyright (c) 2011-2012 Jon Maken
; License: Modified BSD License
; Revision: 2012-05-28 14:06:39 -0600

[Files]
Source: {#RubyPath}\lib\ruby\{#RubyLibVersion}\tk*.rb; DestDir: {app}\lib\ruby\{#RubyLibVersion}; Check: IsTclTk
Source: {#RubyPath}\lib\ruby\{#RubyLibVersion}\tcl*.rb; DestDir: {app}\lib\ruby\{#RubyLibVersion}; Check: IsTclTk
Source: {#RubyPath}\lib\ruby\{#RubyLibVersion}\*-tk.rb; DestDir: {app}\lib\ruby\{#RubyLibVersion}; Check: IsTclTk
Source: {#RubyPath}\lib\ruby\{#RubyLibVersion}\tk\*; DestDir: {app}\lib\ruby\{#RubyLibVersion}\tk; Check: IsTclTk
Source: {#RubyPath}\lib\ruby\{#RubyLibVersion}\tkextlib\*; DestDir: {app}\lib\ruby\{#RubyLibVersion}\tkextlib; Flags: recursesubdirs createallsubdirs; Check: IsTclTk
Source: {#RubyPath}\lib\ruby\{#RubyLibVersion}\{#RubyBuildPlatform}\tcl*.so; DestDir: {app}\lib\ruby\{#RubyLibVersion}\{#RubyBuildPlatform}; Check: IsTclTk
Source: {#RubyPath}\lib\ruby\{#RubyLibVersion}\{#RubyBuildPlatform}\tk*.so; DestDir: {app}\lib\ruby\{#RubyLibVersion}\{#RubyBuildPlatform}; Check: IsTclTk
Source: {#RubyPath}\bin\RubyInstaller.MRI.RubyAssembly\tcl*.dll; DestDir: {app}\bin\RubyInstaller.MRI.RubyAssembly; Check: IsTclTk
Source: {#RubyPath}\bin\RubyInstaller.MRI.RubyAssembly\tk*.dll; DestDir: {app}\bin\RubyInstaller.MRI.RubyAssembly; Check: IsTclTk
Source: {#RubyPath}\lib\tcltk\*; DestDir: {app}\lib\tcltk; Flags: recursesubdirs createallsubdirs; Check: IsTclTk
