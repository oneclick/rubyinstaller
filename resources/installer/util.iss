// Inno Setup utilities
//
// Copyright (c) 2009 Jon Maken
// Revision: 11/03/2009 8:04:17 PM
// License: MIT

// forward declarations
function MungePathish(const SrcList: TStringList; NewData: Array of String; RegValue: String; IsUninstalling: Boolean): Boolean; forward;
procedure ModifyPathish(NewData: Array of String; RegValue, Delim: String); forward;
function StrToList(const SrcString: String; Delim: String): TStringList; forward;
function ListToStr(const SrcList: TStringList; Delim: String): String; forward;

function IsAdmin(): Boolean;
begin
  Result := IsAdminLoggedOn or IsPowerUserLoggedOn;
end;

function IsNotAdmin(): Boolean;
begin
  Result := not (IsAdminLoggedOn or IsPowerUserLoggedOn);
end;

function GetUserHive(): Integer;
begin
  if IsAdminLoggedOn or IsPowerUserLoggedOn then
    Result :=  HKLM
  else
    Result := HKCU;
end;

function GetEnvironmentKey(): String;
begin
  if IsAdmin then
    Result := 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
  else
    Result := 'Environment';
end;

procedure ModifyFileExts(Exts: Array of String);
begin
  ModifyPathish(Exts, 'PATHEXT', ';');
end;

procedure ModifyPath(Exts: Array of String);
begin
  ModifyPathish(Exts, 'PATH', ';');
end;

// Modifies path-like registry keys such as PATH, PATHEXT
procedure ModifyPathish(NewData: Array of String; RegValue, Delim: String);
var
  NeedRegChange: Boolean;
  RootKey: Integer;
  SubKey, OrigData, NewPathish, Tmp, TmpExpandable: String;
  PathishList: TStringList;
begin
  RootKey := GetUserHive;
  SubKey := GetEnvironmentKey;

  try
    RegQueryStringValue(RootKey, SubKey, RegValue, OrigData);
    Log('Original ' + AnsiUppercase(RegValue) + ': ' + OrigData);

    // ensure originally empty users PATHEXT also contains system values
    if (RootKey = HKCU) and (AnsiUppercase(RegValue) = 'PATHEXT') and (OrigData = '') then
    begin
      Log('Empty HKCU ' + AnsiUppercase(RegValue) + ', prepending %PATHEXT% to new value');
      OrigData := ('%' + RegValue + '%');
    end;

    PathishList := StrToList(OrigData, Delim);

    NeedRegChange := MungePathish(PathishList, NewData, RegValue, IsUninstaller);

    if NeedRegChange then
    begin
      NewPathish := ListToStr(PathishList, ';');

      case AnsiUppercase(RegValue) of
        'PATH': RegWriteExpandStringValue(RootKey, SubKey, 'Path', NewPathish);
        'PATHEXT': RegWriteExpandStringValue(RootKey, SubKey, 'PATHEXT', NewPathish);
      end;
      Log(AnsiUppercase(RegValue) + ' updated to: ' + NewPathish);

      // remove values if empty after uninstaller reverts its mods
      if IsUninstaller then
      begin
        if RegQueryStringValue(RootKey, SubKey, RegValue, Tmp) then
        begin
          // If the key is empty or expandable version (%RegValue%), remove it.
          TmpExpandable := '%' + RegValue + '%';
          if (Tmp = '') or (Tmp = TmpExpandable) then
          begin
            RegDeleteValue(RootKey, SubKey, RegValue);
            Log('uninstaller deleted empty ' + AnsiUppercase(RegValue) +
                ' to match original config');
          end;
        end;
      end;
    end else  // no reg change needed
      Log('no changes need for ' + AnsiUppercase(RegValue));
  finally
    PathishList.Free;
  end;
end;

function StrToList(const SrcString: String; Delim: String): TStringList;
var
  PathList: TStringList;
  TmpPath: String;
begin
  PathList := TStringList.Create;

  // empty PATH
  if Length(SrcString) = 0 then Result := PathList;

  if (Length(SrcString) > 0) then
  begin
    // single entry with no trailing ';'
    if Pos(Delim, SrcString) = 0 then
    begin
      PathList.Append(SrcString);

      Result := PathList;
    // single entry with trailing ';'
    // TODO address pathological case of multiple trailing ';' chars?
    end else if Pos(Delim, SrcString) = Length(SrcString) then
    begin
      TmpPath := SrcString;
      StringChangeEx(TmpPath, Delim, '', True);
      PathList.Append(TmpPath);

      Result := PathList;
    end else
    // multiple entries
    begin
      TmpPath := SrcString;
      // clean up a leading ';' pathological case if it exists
      if Pos(Delim, TmpPath) = 1 then TmpPath := Copy(TmpPath, 2, Length(TmpPath));
      while (Pos(Delim, TmpPath) > 0) do
      begin
        PathList.Append(Copy(TmpPath, 1, Pos(Delim, TmpPath) - 1));
        TmpPath := Copy(TmpPath, Pos(Delim, TmpPath) + 1, Length(TmpPath));
      end;
      // add final remaining dir if not empty due to trailing ';'
      if Length(TmpPath) > 0 then PathList.Append(TmpPath);

      Result := PathList;
    end;
  end;
end;

function ListToStr(const SrcList: TStringList; Delim: String): String;
var
  Path: String;
  I: Integer;
begin
  for I := 0 to SrcList.Count - 1 do begin
    if Length(Path) = 0 then
    begin
      Path := SrcList[I];
      Continue;
    end;
    Path := Path + Delim + SrcList[I];
  end;

  Result := Path;
end;

function MungePathish(const SrcList: TStringList; NewData: Array of String;
                      RegValue: String; IsUninstalling: Boolean): Boolean;
var
  RootKey, I, N: Integer;
  Item: String;
  RegChangeFlag: Boolean;
begin
  RegChangeFlag := False;
  RootKey := GetUserHive;

  for N := 0 to GetArrayLength(NewData) - 1 do
  begin
    Item := NewData[N];
    if not IsUninstalling then  // installing...
    begin
      // update PathishList ONLY if new item isn't already in the list
      // DO NOT ASSUME that the installer should duplicate entry or change order!
      if SrcList.IndexOf(Item) = -1 then
      begin
        case AnsiUppercase(RegValue) of
          'PATH': SrcList.Insert(0, Item);
          'PATHEXT': SrcList.Add(AnsiUppercase(Item));
        end;
        RegChangeFlag := True;
      end else  // already in existing config, no need for update; log it
        Log(Item + ' already on ' + AnsiUppercase(RegValue) +
          ' in original config; not modifying ' + AnsiUppercase(RegValue));
    end else  // uninstalling...
    begin
      I := SrcList.IndexOf(Item);
      if I <> -1 then  // found on PathishList, delete it
      begin
        SrcList.Delete(I);
        RegChangeFlag := True;
      end;  // not found on PathishList, no need for registry mod
    end;
  end;

  Result := RegChangeFlag;
end;
