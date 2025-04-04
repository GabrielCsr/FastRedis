unit Acess;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Skia,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Skia, FMX.Layouts, FMX.Objects;

type
  TfrmAcess = class(TForm)
    Rectangle1: TRectangle;
    Layout1: TLayout;
    lblUser: TSkLabel;
    Timer1: TTimer;
    Layout2: TLayout;
    SkLabel2: TSkLabel;
    lblTimingRemaining: TSkLabel;
    Button1: TButton;
    Timer2: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FKey: String;
    FTimeRemaining: Integer;
    FInitialTime: Integer;
    FUser: String;
    procedure UpdateTimeDisplay;
    procedure UpdateUser(const Value: String);
  public
    property Key: String read FKey write FKey;
    property User: String read FUser write UpdateUser;
  end;

var
  frmAcess: TfrmAcess;

implementation

uses
  FastRedis, DateUtils;

{$R *.fmx}

procedure TfrmAcess.FormCreate(Sender: TObject);
begin
  FTimeRemaining := 0;
  FInitialTime := 0;

  Timer2.Interval := 1000;
  Timer2.Enabled := False;
  Timer1.Enabled := False;

  UpdateTimeDisplay;
end;

procedure TfrmAcess.FormShow(Sender: TObject);
begin
  FTimeRemaining := TFastRedis.TimeRemaining(FKey);
  FInitialTime := FTimeRemaining;

  Timer2.Enabled := True;
  Timer1.Enabled := True;
end;

procedure TfrmAcess.UpdateTimeDisplay;
var
  Hours, Minutes, Seconds: Integer;
begin
  Hours := FTimeRemaining div 3600000;
  Minutes := (FTimeRemaining mod 3600000) div 60000;
  Seconds := (FTimeRemaining mod 60000) div 1000;

  lblTimingRemaining.Text := Format('%.2d:%.2d:%.2d', [Hours, Minutes, Seconds]);
end;

procedure TfrmAcess.UpdateUser(const Value: String);
begin
  FUser := Value;
  lblUser.Text := FUser;
end;

procedure TfrmAcess.Button1Click(Sender: TObject);
begin
  TFastRedis.IncreaseExpirationTime(FKey, 5000);
  FTimeRemaining := TFastRedis.TimeRemaining(FKey);
  UpdateTimeDisplay;
end;

procedure TfrmAcess.Timer1Timer(Sender: TObject);
begin
  if FTimeRemaining <= 0 then
    Self.Close;
end;

procedure TfrmAcess.Timer2Timer(Sender: TObject);
begin
  if FTimeRemaining > 0 then
  begin
    FTimeRemaining := FTimeRemaining - 1000;
    UpdateTimeDisplay;

    if FTimeRemaining <= 0 then
      Timer1Timer(Self);
  end;
end;

end.
