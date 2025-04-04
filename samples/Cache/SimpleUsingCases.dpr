program SimpleUsingCases;

uses
  System.StartUpCopy,
  FMX.Forms,
  View in 'View.pas' {frmCache},
  FastRedis in '..\..\src\Core\FastRedis.pas',
  FastRedis.Redis.Configuration in '..\..\src\Core\Configuration\FastRedis.Redis.Configuration.pas',
  FastRedis.Redis.Connection in '..\..\src\Core\Connection\FastRedis.Redis.Connection.pas',
  FastRedisHash in '..\..\src\Core\FastRedisHash.pas',
  FastRedisList in '..\..\src\Core\FastRedisList.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TfrmCache, frmCache);
  Application.Run;
end.
