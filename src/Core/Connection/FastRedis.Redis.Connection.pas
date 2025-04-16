unit FastRedis.Redis.Connection;

interface

uses
  Redis.Commons, Redis.Client, Redis.NetLib.INDY, System.SyncObjs;

type
  TRedisConnection = class
  private
    class var FInstance: IRedisClient;
    class var FLock: TCriticalSection;
    class function CreateConnection(AHost: String = ''; APort: Integer = 0): IRedisClient;
    class function IsConnectionValid(const AClient: IRedisClient): Boolean;
  public
    class function DefaultInstance: IRedisClient;
    class function NewInstanceEx: IRedisClient;
    class procedure Reconnect(var AClient: IRedisClient);
    class function NewInstanceWithReconnect: IRedisClient;
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
end;

class function TRedisConnection.IsConnectionValid(const AClient: IRedisClient): Boolean;
begin
  Result := False;

  if not Assigned(AClient) then
    Exit;

  try
    AClient.&SET('ping', 'pong', 100);
    Result := AClient.GET('ping').HasValue;
  except

  end;
end;

class function TRedisConnection.NewInstanceEx: IRedisClient;
begin
  try
    Result := TRedisConnection.CreateConnection(
     TRedisConfiguration.DefaultConfiguration.Host,
     TRedisConfiguration.DefaultConfiguration.Port);
  except
    on E: Exception do
    begin
      Result := nil;
      raise Exception.CreateFmt('Error on connect Redis: %s', [E.Message]);
    end;
  end;
end;

class function TRedisConnection.NewInstanceWithReconnect: IRedisClient;
var
  LConnected: Boolean;
begin
  Result := nil;
  LConnected := False;

  repeat
    try
      Result := TRedisConnection.NewInstanceEx;
      LConnected := True;
    except
      try
        TRedisConnection.Reconnect(Result);
        LConnected := True;
      except
        On E: Exception do
          if E.Message.Contains('violation') then
            raise Exception.Create(E.Message);
      end;
    end;
  until (LConnected);
end;

class procedure TRedisConnection.Reconnect(var AClient: IRedisClient);
begin
  try
    if not IsConnectionValid(AClient) then
    begin
      AClient := nil;
      AClient := TRedisConnection.NewInstanceEx;
    end;
  except
    on E: Exception do
    begin
      AClient := nil;
      raise Exception.CreateFmt('Error on reconnect Redis: %s', [E.Message]);
    end;
  end;
end;

class function TRedisConnection.DefaultInstance: IRedisClient;
begin
  if not Assigned(FLock) then
    FLock := TCriticalSection.Create;

  FLock.Acquire;
  try
    if not IsConnectionValid(FInstance) then
    begin
      try
        FInstance := nil;
        FInstance := TRedisConnection.CreateConnection(
         TRedisConfiguration.DefaultConfiguration.Host,
         TRedisConfiguration.DefaultConfiguration.Port);
      except
        on E: Exception do
        begin
          FInstance := nil;
          raise Exception.CreateFmt('Erro ao conectar/reconectar no Redis: %s', [E.Message]);
        end;
      end;
    end;

    Result := FInstance;
  finally
    FLock.Release;
  end;
end;

initialization

finalization
  TRedisConnection.FInstance := nil;
  FreeAndNil(TRedisConnection.FLock);

end.

