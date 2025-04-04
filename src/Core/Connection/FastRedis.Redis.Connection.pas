unit FastRedis.Redis.Connection;

interface

uses
  Redis.Commons, Redis.Client, Redis.NetLib.INDY;

type
  TRedisConnection = class
  private
    class var FInstance: IRedisClient;
    class function CreateConnection(AHost: String = ''; APort: Integer = 0): IRedisClient;
  public
    class function Instance(AHost: String = ''; APort: Integer = 0): IRedisClient;
  end;

implementation

uses
  FastRedis.Redis.Configuration, SysUtils;

{ TRedisConnection }

class function TRedisConnection.CreateConnection(AHost: String;
  APort: Integer): IRedisClient;
var
  LRedisConfig: TRedisConfiguration;
begin
  Result := nil;

  try
    if (AHost.Trim.IsEmpty) or (APort = 0) then
    begin
      LRedisConfig := TRedisConfiguration.Load;
      try
        Result := NewRedisClient(LRedisConfig.Host, LRedisConfig.Port);
      finally
        LRedisConfig.Free;
      end;
    end
    else
      Result := NewRedisClient(AHost, APort);
  except
    on E: Exception do
      raise Exception.CreateFmt('Error when connect to Redis: %s', [E.Message]);
  end;
end;

class function TRedisConnection.Instance(AHost: String;
  APort: Integer): IRedisClient;
begin
  try
    if not Assigned(FInstance) then
      FInstance := CreateConnection(AHost, APort);

    Result := FInstance;
  except
    On E: Exception do
      raise Exception.Create(E.Message);
  end;
end;

initialization

finalization
  TRedisConnection.FInstance := nil;

end.
