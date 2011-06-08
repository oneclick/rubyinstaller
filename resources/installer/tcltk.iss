; RubyInstaller Tcl/Tk extension InnoSetup support
; Copyright (c) 2011 Jon Maken
; License: MIT
; Revision: 06/08/2011 4:22:20 PM

[Files]
Source: {#RubyPath}\lib\ruby\{#RubyLibVersion}\tk*.rb; DestDir: {app}\lib\ruby\{#RubyLibVersion}; Check: IsTclTk
Source: {#RubyPath}\lib\ruby\{#RubyLibVersion}\tcl*.rb; DestDir: {app}\lib\ruby\{#RubyLibVersion}; Check: IsTclTk
Source: {#RubyPath}\lib\ruby\{#RubyLibVersion}\*-tk.rb; DestDir: {app}\lib\ruby\{#RubyLibVersion}; Check: IsTclTk
Source: {#RubyPath}\lib\ruby\{#RubyLibVersion}\tk\*; DestDir: {app}\lib\ruby\{#RubyLibVersion}\tk; Check: IsTclTk
Source: {#RubyPath}\lib\ruby\{#RubyLibVersion}\tkextlib\*; DestDir: {app}\lib\ruby\{#RubyLibVersion}\tkextlib; Flags: recursesubdirs createallsubdirs; Check: IsTclTk
Source: {#RubyPath}\..\tcl\bin\*; DestDir: {app}\bin; Excludes: "*.exe"; Check: IsTclTk
Source: {#RubyPath}\..\tk\bin\*; DestDir: {app}\bin; Excludes: "*.exe"; Check: IsTclTk
Source: {#RubyPath}\..\tcl\lib\*; DestDir: {app}\lib\tk; Excludes: "*.a,*.sh"; Flags: recursesubdirs createallsubdirs; Check: IsTclTk
Source: {#RubyPath}\..\tk\lib\*; DestDir: {app}\lib\tk; Excludes: "*.a,*.sh"; Flags: recursesubdirs createallsubdirs; Check: IsTclTk
