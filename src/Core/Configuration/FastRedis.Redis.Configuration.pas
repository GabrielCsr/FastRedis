unit FastRedis.Redis.Configuration;

interface

type
  TRedisConfiguration = class
  private
    FHost: String;
    FPort: Integer;
    class var FConfiguration: TRedisConfiguration;
  public
    property Host: String read FHost write FHost;
    property Port: Integer read FPort write FPort;
    class function Load: TRedisConfiguration;
    constructor Create;
    class function DefaultConfiguration: TRedisConfiguration;
  end;

implementation

uses
  rest.Json, system.ioutils, sysutils, JSON, JSON.Serializers;

{ TRedisConfiguration }

constructor TRedisConfiguration.Create;
begin
  FHost := '';
  FPort := 0;
end;

class function TRedisConfiguration.DefaultConfiguration: TRedisConfiguration;
begin
  if not Assigned(FConfiguration) then
    FConfiguration := TRedisConfiguration.Create;

  Result := FConfiguration;
end;

class function TRedisConfiguration.Load: TRedisConfiguration;
var
  LFilePath: String;
  LJSONObject: TJSONObject;
begin
  LFilePath := ExtractFilePath(ParamStr(0)) + 'redisConfig.json';

  if not FileExists(LFilePath) then
  begin
    LJSONObject := TJSONValue.ParseJSONValue('{"Host": "127.0.0.1", "Port": 6379}') as TJSONObject;
    try
      TFile.WriteAllText('redisConfig.json', TJSONAncestor(LJSONObject).Format(2));
    finally
      FreeAndNil(LJSONObject);
    end;
  end;

  Result := TJson.JsonToObject<TRedisConfiguration>(TFile.ReadAllText(LFilePath));
end;

initialization

finalization
  TRedisConfiguration.FConfiguration.Free;

end.
