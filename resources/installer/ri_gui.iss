// RubyInstaller Inno Setup GUI Customizations
//
// Copyright (c) 2009 Jon Maken
// Revision: 11/04/2009 11:07:27 AM
// License: MIT

var
  PathChkBox, PathExtChkBox: TCheckBox;

function IsAssociated(): Boolean;
begin
  Result := PathExtChkBox.Checked;
end;

function IsModifyPath(): Boolean;
begin
  Result := PathChkBox.Checked;
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
  Page: TWizardPage;
  HostPage: TNewNotebookPage;
  URLText, TmpLabel: TNewStaticText;
begin

  {* Main wizard page colorization *}

  // light green = $00eafcf5
  WizardForm.InnerPage.Color := $00fafaff;
  WizardForm.Color := clWhite;


  {* Path and file association task check boxes *}

  Page := PageFromID(wpSelectDir);
  
  PathChkBox := TCheckBox.Create(Page);
  PathChkBox.Parent := Page.Surface;
  PathChkBox.State := cbUnchecked;
  PathChkBox.Caption := 'Add Ruby executables to your PATH';
  PathChkBox.Alignment := taRightJustify;
  PathChkBox.Top := ScaleY(95);
  PathChkBox.Left := ScaleX(18);
  PathChkBox.Width := Page.SurfaceWidth;
  PathChkBox.Height := ScaleY(17);

  PathExtChkBox := TCheckBox.Create(Page);
  PathExtChkBox.Parent := Page.Surface;
  PathExtChkBox.State := cbUnchecked;
  PathExtChkBox.Caption := 'Associate .rb and .rbw files with this Ruby installation';
  PathExtChkBox.Alignment := taRightJustify;
  PathExtChkBox.Top := ScaleY(112);
  PathExtChkBox.Left := ScaleX(18);
  PathExtChkBox.Width := Page.SurfaceWidth;
  PathExtChkBox.Height := ScaleY(17);


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

end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpSelectDir then
    WizardForm.NextButton.Caption := '&Install';
end;
