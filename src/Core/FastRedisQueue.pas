unit FastRedisQueue;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  Redis.Commons, Redis.Client, Redis.NetLib.INDY;

type
  TFastRedisQueue = class
  private
    type
      TSubscriptionThread = class(TThread)
      private
        FOwner: TFastRedisQueue;
        FChannel: string;
        FCallback: TProc<string>;
        FRedis: IRedisClient;
      protected
        procedure Execute; override;
      public
        constructor Create(
         AOwner: TFastRedisQueue;
         const AChannel: string;
         const ACallback: TProc<string>);

        destructor Destroy; override;
      end;

  private
    FThreads: TObjectDictionary<string, TSubscriptionThread>;
    FChannelCallbacks: TDictionary<string, TProc<string>>;
    FLock: TObject;
    FAutomaticReconnect: Boolean;

    procedure ProcessMessage(const AChannel, AMessage: string);
  public
    constructor Create(AAutomaticReconnect: Boolean = True);
    destructor Destroy; override;

    procedure Subscribe(const AChannel: string; const ACallback: TProc<string>);
    procedure Unsubscribe(const AChannel: string);
    procedure Publish(const AChannel, AMessage: string);
  end;

implementation

uses
  FastRedis.Redis.Connection;

{ TFastRedisQueue }

constructor TFastRedisQueue.Create(AAutomaticReconnect: Boolean);
begin
  FChannelCallbacks := TDictionary<string, TProc<string>>.Create;
  FThreads := TObjectDictionary<string, TSubscriptionThread>.Create([doOwnsValues]);
  FLock := TObject.Create;
  FAutomaticReconnect := AAutomaticReconnect;
end;

destructor TFastRedisQueue.Destroy;
begin
  FreeAndNil(FLock);
  FreeAndNil(FThreads);
  FreeAndNil(FChannelCallbacks);
  inherited;
end;

procedure TFastRedisQueue.Subscribe(const AChannel: string; const ACallback: TProc<string>);
begin
  TMonitor.Enter(FLock);
  try
    if FThreads.ContainsKey(AChannel) then
      Exit;

    FChannelCallbacks.AddOrSetValue(AChannel, ACallback);
    FThreads.Add(AChannel, TSubscriptionThread.Create(Self, AChannel, ACallback));
  finally
    TMonitor.Exit(FLock);
  end;
end;

procedure TFastRedisQueue.Unsubscribe(const AChannel: string);
var
  Thread: TSubscriptionThread;
begin
  TMonitor.Enter(FLock);
  try
    if FThreads.TryGetValue(AChannel, Thread) then
    begin
      Thread.Terminate;
      Thread.WaitFor;
      FThreads.Remove(AChannel);
      FChannelCallbacks.Remove(AChannel);
    end;
  finally
    TMonitor.Exit(FLock);
  end;
end;

procedure TFastRedisQueue.ProcessMessage(const AChannel, AMessage: string);
var
  Callback: TProc<string>;
  LUtf8Message: string;
begin
  TMonitor.Enter(FLock);
  try
    if FChannelCallbacks.TryGetValue(AChannel, Callback) then
    begin
      LUtf8Message := TEncoding.UTF8.GetString(TEncoding.Default.GetBytes(AMessage));
      Callback(LUtf8Message);
    end;
  finally
    TMonitor.Exit(FLock);
  end;
end;

procedure TFastRedisQueue.Publish(const AChannel, AMessage: string);
begin
  try
    TRedisConnection.DefaultInstance.&PUBLISH(AChannel, AMessage);
  except
    on E: Exception do
    begin
      raise Exception.CreateFmt('Error on publish message %s: %s', [AChannel, E.Message]);
    end;
  end;
end;

{ TSubscriptionThread }

constructor TFastRedisQueue.TSubscriptionThread.Create(
  AOwner: TFastRedisQueue;
  const AChannel: string;
  const ACallback: TProc<string>);
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FOwner := AOwner;
  FChannel := AChannel;
  FCallback := ACallback;

  if FOwner.FAutomaticReconnect then
    FRedis := TRedisConnection.NewInstanceWithReconnect
  else
    FRedis := TRedisConnection.NewInstanceEx;
end;

destructor TFastRedisQueue.TSubscriptionThread.Destroy;
begin
  inherited;
end;

procedure TFastRedisQueue.TSubscriptionThread.Execute;
var
  LMessageHandler: TProc<string, string>;
  LContinueCallback: TRedisTimeoutCallback;
begin
  {$REGION 'MessageHandler'}
  LMessageHandler :=
   procedure(AChannel, AMessage: String)
   begin
     if Terminated then
       Exit;

     FOwner.ProcessMessage(AChannel, AMessage);
   end;
  {$ENDREGION}
  {$REGION 'CountinueCallback'}
  LContinueCallback :=
   function: boolean
   begin
     Result := not Terminated;
   end;
  {$ENDREGION}

  while not Terminated do
  begin
    try
      FRedis.SetCommandTimeout(1000);
      FRedis.SUBSCRIBE([FChannel], LMessageHandler, LContinueCallback);
    except
      on E: Exception do
      begin
        if Terminated then
          Break;

        if FOwner.FAutomaticReconnect then
        begin
          FRedis := TRedisConnection.NewInstanceWithReconnect;
        end;
      end;
    end;
  end;
end;

end.
