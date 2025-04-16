unit FastRedis;

interface

uses
  Redis.Commons, Redis.Client, Redis.NetLib.INDY,
  System.Rtti, System.SysUtils, System.JSON, System.TypInfo, System.Generics.Collections,
  FastRedisHash, FastRedisList, FastRedis.Redis.Configuration, FastRedisQueue;

type
  TFastRedis = class
  private
    class var FHash: TFastRedisHash;
    class var FList: TFastRedisList;
    class procedure FreeInstances;
  public
    class procedure Configuration(AHost: String; APort: integer);

    class function TypeOfKey(const AKey: String): String;

    {String}
    class procedure Save<T: Class, Constructor>(const AKey: string;
                                                const AValue: T;
                                                Expiration: Integer = 0); overload;

    class procedure Save(const AKey: string;
                         const AValue: String;
                         Expiration: Integer = 0); overload;

    class function Load<T: Class, Constructor>(const AKey: string): T;

    class procedure Delete(const AKey: string);
    class function Exists(const AKey: string): Boolean;
    class function TimeRemaining(const AKey: string): Integer;
    class function Keys(const APattern: string = '*'): TArray<string>;
    class procedure IncreaseExpirationTime(const AKey: String; ATimeInSecounds: Integer);
    class procedure SetExpirationTime(const AKey: String; ATimeInSecounds: Integer);

    {Hash}
    class function Hash: TFastRedisHash;

    {List}
    class function List: TFastRedisList;

    {PubSub}
    class function Queue(AAutomaticReconnect: Boolean = True): TFastRedisQueue;
  end;

implementation

uses
  REST.Json, FastRedis.Redis.Connection, Redis.Values;

{ TFastRedis }

class procedure TFastRedis.Save(const AKey, AValue: String;
  Expiration: Integer);
begin
  TRedisConnection.DefaultInstance.&SET(AKey, AValue);

  if Expiration > 0 then
    SetExpirationTime(AKey, Expiration);

end;

class procedure TFastRedis.Save<T>(const AKey: string; const AValue: T; Expiration: Integer = 0);
var
  LJSONValue: string;
  LContext: TRttiContext;
  LRttiType: TRttiType;
begin
  LContext := TRttiContext.Create;
  try
    LRttiType := LContext.GetType(TypeInfo(T));

    if LRttiType.TypeKind = tkClass then
      LJSONValue := TJson.ObjectToJsonString(TObject(Pointer(@AValue)^))
    else
      LJSONValue := TValue.From<T>(AValue).ToString;

    TRedisConnection.DefaultInstance.&SET(AKey, LJSONValue);

    if Expiration > 0 then
      SetExpirationTime(AKey, Expiration);
  finally
    LContext.Free;
  end;
end;

class procedure TFastRedis.SetExpirationTime(const AKey: String;
  ATimeInSecounds: Integer);
begin
  TRedisConnection.DefaultInstance.EXPIRE(AKey, ATimeInSecounds);
end;

class function TFastRedis.List: TFastRedisList;
begin
  if not Assigned(FList) then
    TFastRedis.FList := TFastRedisList.Create;

  Result := FList;
end;

class function TFastRedis.Load<T>(const AKey: string): T;
var
  Context: TRttiContext;
  RttiType: TRttiType;
  LValue: TRedisString;
begin
  LValue := TRedisConnection.DefaultInstance.GET(AKey);

  if LValue.IsNull then
    Exit(nil);

  Context := TRttiContext.Create;
  try
    RttiType := Context.GetType(TypeInfo(T));

    if RttiType.TypeKind = tkClass then
      Result := TJson.JsonToObject<T>(LValue.Value)
    else
      Result := TValue.From<string>(LValue.Value).AsType<T>;
  finally
    Context.Free;
  end;
end;

class function TFastRedis.Queue(AAutomaticReconnect: Boolean): TFastRedisQueue;
begin
  Result := TFastRedisQueue.Create(AAutomaticReconnect);
end;

class procedure TFastRedis.Configuration(AHost: String; APort: integer);
begin
  TRedisConfiguration.DefaultConfiguration.Host := AHost;
  TRedisConfiguration.DefaultConfiguration.Port := APort;
end;

class procedure TFastRedis.Delete(const AKey: string);
begin
  TRedisConnection.DefaultInstance.DEL([AKey]);
end;

class function TFastRedis.Exists(const AKey: string): Boolean;
begin
  Result := TRedisConnection.DefaultInstance.EXISTS(AKey);
end;

class procedure TFastRedis.FreeInstances;
begin
  if Assigned(FHash) then
    FreeAndNil(FHash);

  if Assigned(FList) then
    FreeAndNil(FList);
end;

class function TFastRedis.Hash: TFastRedisHash;
begin
  if not Assigned(FHash) then
    FHash := TFastRedisHash.Create;

  Result := FHash;
end;

class procedure TFastRedis.IncreaseExpirationTime(const AKey: String;
  ATimeInSecounds: Integer);
begin
  if not Exists(AKey) then
    Exit;


  TRedisConnection.DefaultInstance.EXPIRE(AKey, TimeRemaining(AKey) + ATimeInSecounds);
end;

class function TFastRedis.TimeRemaining(const AKey: string): Integer;
begin
  Result := TRedisConnection.DefaultInstance.TTL(AKey);
end;

class function TFastRedis.TypeOfKey(const AKey: String): String;
begin
  Result := TRedisConnection.DefaultInstance.&TYPE(AKey);
end;

class function TFastRedis.Keys(const APattern: string): TArray<string>;
var
  LKeys: TRedisArray;
  LKey: TRedisString;
begin
  SetLength(Result, 0);

  LKeys := TRedisConnection.DefaultInstance.KEYS(APattern);

  if LKeys.IsNull then
    Exit;

  for LKey in LKeys.Value do
  begin
    if LKey.IsNull then
      Continue;

    SetLength(Result, Length(Result) + 1);
    Result[High(Result)] := LKey.Value;
  end;
end;

initialization

finalization
  TFastRedis.FreeInstances;

end.

