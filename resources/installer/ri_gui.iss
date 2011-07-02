// RubyInstaller Inno Setup GUI Customizations
//
// Copyright (c) 2009-2011 Jon Maken
// Revision: 07/02/2011 2:22:39 PM
// License: Modified BSD License

const
  ChkBoxBaseY = 95;
  ChkBoxBaseHeight = 17;
  ChkBoxBaseLeft = 18;

var
  PathChkBox, PathExtChkBox, TclTkChkBox: TCheckBox;

function IsAssociated(): Boolean;
begin
  Result := PathExtChkBox.Checked;
end;

function IsModifyPath(): Boolean;
begin
  Result := PathChkBox.Checked;
end;

function IsTclTk(): Boolean;
begin
  Result := TclTkChkBox.Checked;
end;


procedure ParseSilentTasks();
var
  I, N: Integer;
  Param: String;
  Tasks: TStringList;
begin
  {* parse command line args for silent install tasks *}
  for I := 0 to ParamCount do
  begin
    Param := AnsiUppercase(ParamStr(I));
    if Pos('/TASKS', Param) <> 0 then
    begin
      Param := Trim(Copy(Param, Pos('=', Param) + 1, Length(Param)));
      try
        // TODO check for too many tasks to prevent overflow??
        Tasks := StrToList(Param, ',');
        for N := 0 to Tasks.Count - 1 do
          case Trim(Tasks.Strings[N]) of
            'ADDTK': TclTkChkBox.State := cbChecked;
            'MODPATH': PathChkBox.State := cbChecked;
            'ASSOCFILES': PathExtChkBox.State := cbChecked;
          end;
      finally
        Tasks.Free;
      end;
    end;
  end;
end;

procedure URLText_OnClick(Sender: TObject);
var
  ErrorCode: Integer;
begin
  if Sender is TNewStaticText then
    ShellExec('open', TNewStaticText(Sender).Caption, '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

procedure InitializeWizard;
var
  ChkBoxCurrentY: Integer;
  Page: TWizardPage;
  HostPage: TNewNotebookPage;
  URLText, TmpLabel: TNewStaticText;
begin

  {* Path and file association task check boxes *}

  Page := PageFromID(wpSelectDir);
  ChkBoxCurrentY := ChkBoxBaseY;

#ifndef NoTk
  TclTkChkBox := TCheckBox.Create(Page);
  TclTkChkBox.Parent := Page.Surface;
  TclTkChkBox.State := cbUnchecked;
  TclTkChkBox.Caption := 'Install Tcl/Tk support';
  TclTkChkBox.Alignment := taRightJustify;
  TclTkChkBox.Top := ScaleY(ChkBoxBaseY);
  TclTkChkBox.Left := ScaleX(ChkBoxBaseLeft);
  TclTkChkBox.Width := Page.SurfaceWidth;
  TclTkChkBox.Height := ScaleY(ChkBoxBaseHeight);
  ChkBoxCurrentY := ChkBoxCurrentY + ChkBoxBaseHeight;
#endif

  PathChkBox := TCheckBox.Create(Page);
  PathChkBox.Parent := Page.Surface;
  PathChkBox.State := cbUnchecked;
  PathChkBox.Caption := 'Add Ruby executables to your PATH';
  PathChkBox.Alignment := taRightJustify;
  PathChkBox.Top := ScaleY(ChkBoxCurrentY);
  PathChkBox.Left := ScaleX(ChkBoxBaseLeft);
  PathChkBox.Width := Page.SurfaceWidth;
  PathChkBox.Height := ScaleY(ChkBoxBaseHeight);
  ChkBoxCurrentY := ChkBoxCurrentY + ChkBoxBaseHeight;

  PathExtChkBox := TCheckBox.Create(Page);
  PathExtChkBox.Parent := Page.Surface;
  PathExtChkBox.State := cbUnchecked;
  PathExtChkBox.Caption := 'Associate .rb and .rbw files with this Ruby installation';
  PathExtChkBox.Alignment := taRightJustify;
  PathExtChkBox.Top := ScaleY(ChkBoxCurrentY);
  PathExtChkBox.Left := ScaleX(ChkBoxBaseLeft);
  PathExtChkBox.Width := Page.SurfaceWidth;
  PathExtChkBox.Height := ScaleY(ChkBoxBaseHeight);

  ParseSilentTasks;


  {* Labels and links back to RubyInstaller project pages *}

  HostPage := WizardForm.FinishedPage;

  TmpLabel := TNewStaticText.Create(HostPage);
  TmpLabel.Parent := HostPage;
  TmpLabel.Top := ScaleY(180);
  TmpLabel.Left := ScaleX(176);
  TmpLabel.AutoSize := True;
  TmpLabel.Caption := 'Web Site:';

  URLText := TNewStaticText.Create(HostPage);
  URLText.Parent := HostPage;
  URLText.Top := TmpLabel.Top;
  URLText.Left := TmpLabel.Left + TmpLabel.Width + ScaleX(4);
  URLText.AutoSize := True;
  URLText.Caption := 'http://rubyinstaller.org';
  URLText.Cursor := crHand;
  URLText.Font.Color := clBlue;
  URLText.OnClick := @URLText_OnClick;

  TmpLabel := TNewStaticText.Create(HostPage);
  TmpLabel.Parent := HostPage;
  TmpLabel.Top := ScaleY(196);
  TmpLabel.Left := ScaleX(176);
  TmpLabel.AutoSize := True;
  TmpLabel.Caption := 'Support group:';

  URLText := TNewStaticText.Create(HostPage);
  URLText.Parent := HostPage;
  URLText.Top := TmpLabel.Top;
  URLText.Left := TmpLabel.Left + TmpLabel.Width + ScaleX(4);
  URLText.AutoSize := True;
  URLText.Caption := 'http://groups.google.com/group/rubyinstaller';
  URLText.Cursor := crHand;
  URLText.Font.Color := clBlue;
  URLText.OnClick := @URLText_OnClick;

  TmpLabel := TNewStaticText.Create(HostPage);
  TmpLabel.Parent := HostPage;
  TmpLabel.Top := ScaleY(212);
  TmpLabel.Left := ScaleX(176);
  TmpLabel.AutoSize := True;
  TmpLabel.Caption := 'Wiki:';

  URLText := TNewStaticText.Create(HostPage);
  URLText.Parent := HostPage;
  URLText.Top := TmpLabel.Top;
  URLText.Left := TmpLabel.Left + TmpLabel.Width + ScaleX(4);
  URLText.AutoSize := True;
  URLText.Caption := 'http://wiki.github.com/oneclick/rubyinstaller';
  URLText.Cursor := crHand;
  URLText.Font.Color := clBlue;
  URLText.OnClick := @URLText_OnClick;

  TmpLabel := TNewStaticText.Create(HostPage);
  TmpLabel.Parent := HostPage;
  TmpLabel.Top := ScaleY(245);
  TmpLabel.Left := ScaleX(176);
  TmpLabel.AutoSize := True;
  TmpLabel.Caption := 'How about a toolkit for building native C RubyGems?';

  TmpLabel := TNewStaticText.Create(HostPage);
  TmpLabel.Parent := HostPage;
  TmpLabel.Top := ScaleY(260);
  TmpLabel.Left := ScaleX(176);
  TmpLabel.AutoSize := True;
  TmpLabel.Caption := 'DevKit:';

  URLText := TNewStaticText.Create(HostPage);
  URLText.Parent := HostPage;
  URLText.Top := TmpLabel.Top;
  URLText.Left := TmpLabel.Left + TmpLabel.Width + ScaleX(4);
  URLText.AutoSize := True;
  URLText.Caption := 'http://rubyinstaller.org/add-ons/devkit';
  URLText.Cursor := crHand;
  URLText.Font.Color := clBlue;
  URLText.OnClick := @URLText_OnClick;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpSelectDir then
    WizardForm.NextButton.Caption := '&Install';
end;
