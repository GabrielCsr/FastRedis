program Queue;

uses
  Vcl.Forms,
  View in 'View.pas' {Form1},
  FastRedis in '..\..\src\Core\FastRedis.pas',
  FastRedisHash in '..\..\src\Core\FastRedisHash.pas',
  FastRedisList in '..\..\src\Core\FastRedisList.pas',
  FastRedisQueue in '..\..\src\Core\FastRedisQueue.pas',
  FastRedis.Redis.Connection in '..\..\src\Core\Connection\FastRedis.Redis.Connection.pas',
  FastRedis.Redis.Configuration in '..\..\src\Core\Configuration\FastRedis.Redis.Configuration.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
