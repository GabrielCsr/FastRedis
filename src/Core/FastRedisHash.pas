unit FastRedisHash;

interface

uses
  System.Generics.Collections;

type
  TFastRedisHash = class
  private
    class function NamesAndValuesFromProperties<T: Class>(AClassInstance: T;
      AOnlyName: Boolean = False): TPair<TArray<String>, TArray<String>>;
  public
    class procedure Save<T: class>(const AKey: string; const AValue: T); overload;
    class procedure Save<T: class>(const AKey, AField: string; const AValue: T); overload;
    class procedure Save(const AKey, AField, AValue: string); overload;

    class function Load<T: class, constructor>(const AKey: String): T; overload;
    class function Load<T: class, constructor>(const AKey, AField: String): T; overload;
    class function Load(const AKey, AField: String): String; overload;

    class function Exists(const AKey, AField: String): Boolean; overload;
    class function Exists<T: class, constructor>(const AKey: String): Boolean; overload;

    class procedure Delete<T: class, constructor>(const AKey: String); overload;
    class procedure Delete(const AKey: String; AFields: TArray<String>); overload;
  end;

implementation

uses
  System.Rtti, SysUtils, FastRedis.Redis.Connection, REST.Json, Redis.Values,
  System.TypInfo, StrUtils;

{ TFastRedisHash }

class function TFastRedisHash.Load<T>(const AKey: String): T;
var
  LArray: TRedisArray;
  LFields: TArray<String>;
  LField: TRedisString;
  LContext: TRTTIContext;
  LType: TRTTIType;
  LProperty: TRTTIProperty;
  I: Integer;
begin
  SetLength(LFields,0);
  Result := T.Create;
  LContext := TRTTIContext.Create;
  try
    LType := LContext.GetType(Result.ClassType);
    
    LFields := NamesAndValuesFromProperties<T>(Result, True).Key;

    if not (Length(LFields) > 0) then
      Exit;
      
    LArray := TRedisConnection.Instance.HMGET(AKey, LFields);

    if LArray.IsNull  then
      Exit;

    I := 0;  
    for LField in LArray.Value do
    begin
      if LField.IsNull then
        Continue;

      LProperty := LType.GetProperty(LFields[I]);
      Inc(I);
      
      if not Assigned(LProperty) then
        Continue;
        
      if LProperty.IsWritable then
      begin
        LProperty.SetValue(TObject(Result), LField.Value);
      end;
    end;

  finally
    SetLength(LFields,0);
    LContext.Free;
  end;
end;

class procedure TFastRedisHash.Delete(const AKey: String;
  AFields: TArray<String>);
begin
  TRedisConnection.Instance.HDEL(AKey, AFields);
end;

class procedure TFastRedisHash.Delete<T>(const AKey: String);
var
  LInstance: T;
begin
  LInstance := T.Create;
  try
    TRedisConnection.Instance.HDEL(AKey, NamesAndValuesFromProperties<T>(LInstance).Key);
  finally
    LInstance.Free;
  end;
end;

class function TFastRedisHash.Exists(const AKey, AField: String): Boolean;
begin
  Result := TRedisConnection.Instance.HEXISTS(AKey, AField);
end;

class function TFastRedisHash.Exists<T>(const AKey: String): Boolean;
var
  Linstance: T;
  LField: String;
begin
  Linstance := T.Create;
  try
    LField := NamesAndValuesFromProperties<T>(LInstance, True).Key[0];
    Result := TRedisConnection.Instance.HEXISTS(AKey, LField);
  finally
    Linstance.Free;
  end;
end;

class function TFastRedisHash.Load(const AKey, AField: String): String;
var
  LValue: String;
begin
  LValue := '';
  TRedisConnection.Instance.HGET(AKey, AField, LValue);
  Result := LValue;
end;

class function TFastRedisHash.Load<T>(const AKey, AField: String): T;
var
  LValue: String;
begin
  Result := nil;

  if MatchStr('', [AKey, AField]) then
    raise Exception.Create('Key or field don''''t informed');

  TRedisConnection.Instance.HGET(AKey, AField, LValue);

  if LValue.IsEmpty then
    Exit;

  Result := TJson.JsonToObject<T>(LValue);
end;

class function TFastRedisHash.NamesAndValuesFromProperties<T>(AClassInstance: T;
  AOnlyName: Boolean = False): TPair<TArray<String>, TArray<String>>;
var
  LContext:  TRttiContext;
  LType:     TRttiType;
  LProperty: TRttiProperty;
  LValue: String;
begin
  Result.Create([], []);
  LContext := TRttiContext.Create;
  try
    LType := LContext.GetType(AClassInstance.ClassType);
    for LProperty in LType.GetProperties do
    begin
      LValue := LProperty.GetValue(TObject(AClassInstance)).ToString;

      if (LValue.Trim.IsEmpty) and (not AOnlyName) then
        Continue;

      SetLength(Result.Key, Length(Result.Key) + 1);
      Result.Key[High(Result.Key)]     := LProperty.Name;

      if not AOnlyName then
      begin
        SetLength(Result.Value, Length(Result.Value) + 1);
        Result.Value[High(Result.Value)] := LValue;
      end;      
    end;
  finally
    LContext.Free;
  end;
end;

class procedure TFastRedisHash.Save(const AKey, AField, AValue: string);
begin
  TRedisConnection.Instance.HSET(AKey, AField, AValue);
end;

class procedure TFastRedisHash.Save<T>(const AKey: string; const AValue: T);
var
  LPairFieldsValues: TPair<TArray<String>, TArray<String>>;
begin
  if not Assigned(AValue) then
    Exit;

  try
    LPairFieldsValues := NamesAndValuesFromProperties<T>(AValue);

    if Length(LPairFieldsValues.Key) > 0 then
      TRedisConnection.Instance.HMSET(AKey, LPairFieldsValues.Key, LPairFieldsValues.Value);
  except
    On E: Exception do
      raise Exception.Create('Error on save hash. ' + E.Message);
  end;
end;

class procedure TFastRedisHash.Save<T>(const AKey, AField: string;
  const AValue: T);
begin
  if not Assigned(AValue) then
    Exit;

  TRedisConnection.Instance.HSET(AKey, AField, TJson.ObjectToJsonString(AValue));
end;

end.
