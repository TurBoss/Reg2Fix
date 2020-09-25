unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  FileUtil,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  StdCtrls,
  Windows,
  registry;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    UnitsCombo: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure UnitsComboChange(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  WantedUnit: string;
  Drive: Char;
  DriveLetter: string;
  OldMode: Word;
  CurrentUnit: string;
  reg: TRegistry;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin

  // Empty Floppy or Zip drives can generate a Windows error.
  // We disable system errors during the listing.
  // Note that another way to skip these errors would be to use DEVICE_IO_CONTROL.
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  UnitsCombo.Items.Clear;
  UnitsCombo.Text := 'Select Unit';

  try
    // Search all drive letters
    for Drive := 'A' to 'Z' do
    begin
      DriveLetter := Drive + ':\';

      case GetDriveType(PChar(DriveLetter)) of
        // DRIVE_REMOVABLE: UnitsCombo.Items.Add(DriveLetter + ' Floppy');
        // DRIVE_FIXED:     UnitsCombo.Items.Add(DriveLetter + ' Fixed');
        // DRIVE_REMOTE:    UnitsCombo.Items.Add(DriveLetter + ' Network');
        DRIVE_CDROM:        UnitsCombo.Items.Add(DriveLetter);
        // DRIVE_RAMDISK:   UnitsCombo.Items.Add(DriveLetter + ' RAM');
      end;
    end;

  finally
    // Restores previous Windows error mode.
    SetErrorMode(OldMode);
  end;

  reg := TRegistry.Create;
  try
     Label3.Caption := 'Error in reg path';
    // Navigate to proper "directory":
    reg.RootKey := HKEY_LOCAL_MACHINE;
    if reg.OpenKeyReadOnly('SOFTWARE\WOW6432Node\Square Soft, Inc.\Final Fantasy VII') then
      begin
        CurrentUnit := reg.ReadString('DataDrive'); //read the value of the default name
        Label3.Caption := CurrentUnit;
       end
    else
      begin
        Label3.Caption := 'Error in reg value';
      end;
  finally
    reg.Free;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if WantedUnit <> '' then
    begin
      reg := TRegistry.Create;
      try
         Label3.Caption := 'Error in reg path';
        // Navigate to proper "directory":
        reg.RootKey := HKEY_LOCAL_MACHINE;
        if reg.OpenKey('SOFTWARE\Square Soft, Inc.\Final Fantasy VII', True) then
          begin
            reg.WriteString('DataDrive',WantedUnit);
            reg.WriteString('MoviePath',WantedUnit + 'Movies');
            reg.CloseKey;
           end
        else
          begin
            Label3.Caption := 'Error in reg value';
          end;
        if reg.OpenKey('SOFTWARE\WOW6432Node\Square Soft, Inc.\Final Fantasy VII', True) then
          begin
            reg.WriteString('DataDrive',WantedUnit);
            reg.WriteString('MoviePath',WantedUnit + 'Movies');
            reg.CloseKey;
           end
        else
          begin
            Label3.Caption := 'Error in reg value';
          end;
      finally
        reg.Free;
        Label3.Caption := WantedUnit;
      end;
    end
  else
    begin
      ShowMessage('choose a unit to change');
    end;
end;

procedure TForm1.UnitsComboChange(Sender: TObject);
begin
    WantedUnit := UnitsCombo.Items[UnitsCombo.ItemIndex];
end;
end.

