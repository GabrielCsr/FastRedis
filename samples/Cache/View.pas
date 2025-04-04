unit View;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs;

type
  TfrmCache = class(TForm)
    procedure FormShow(Sender: TObject);
  end;

  TCostumer = class
  private
    FName: String;
    FAge: Integer;
    FID: Integer;
  public
    constructor Create; //needed
    property ID: Integer read FID write FID;
    property Name: String read FName write FName;
    property Age: Integer read FAge write FAge;
  end;

var
  frmCache: TfrmCache;

implementation

uses
  FastRedis, FastRedis.Redis.Configuration;

{$R *.fmx}

{ TCostumer }

constructor TCostumer.Create;
begin
  FID   := 0;
  FName := '';
  FAge  := 0;
end;

procedure TfrmCache.FormShow(Sender: TObject);
var
  LCostumer: TCostumer;
  LFastRedis: TFastRedis;
begin
  LCostumer := TCostumer.Create;
  LCostumer.ID   := 1;
  LCostumer.Name := 'Gabriel Teixeira';
  LCostumer.Age  := 20;

  try
    TFastRedis.Save<TCostumer>('Key', LCostumer, 100);
  finally
    LCostumer.Free;
  end;

  LCostumer := TFastRedis.Load<TCostumer>('Key');
  if Assigned(LCostumer) then
  begin
    ShowMessageFmt('Nome: %s' + sLineBreak + 'Idade: %d', [LCostumer.Name, LCostumer.Age]);
    LCostumer.Free;
  end;

  if TFastRedis.Exists('Key') then
  begin
    ShowMessageFmt('Tempo restante: %d segundo(s).', [LFastRedis.TimeRemaining('Key')]);

    LFastRedis.IncreaseExpirationTime('Key', 1000);

    ShowMessageFmt('Tempo restante pós incremento: %d segundo(s).', [LFastRedis.TimeRemaining('Key')]);

    LFastRedis.Delete('Key');
  end;

  LFastRedis.Save('String', 'String Value');
end;

end.
