program Login;

uses
  System.StartUpCopy,
  FMX.Forms,
  View in 'View.pas' {frmLogin},
  Account.Entity in 'Account.Entity.pas',
  FastRedis in '..\..\src\Core\FastRedis.pas',
  FastRedis.Redis.Configuration in '..\..\src\Core\Configuration\FastRedis.Redis.Configuration.pas',
  FastRedis.Redis.Connection in '..\..\src\Core\Connection\FastRedis.Redis.Connection.pas',
  FastRedisHash in '..\..\src\Core\FastRedisHash.pas',
  Acess in 'Acess.pas' {frmAcess},
  FastRedisList in '..\..\src\Core\FastRedisList.pas',
  FastRedisQueue in '..\..\src\Core\FastRedisQueue.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TfrmLogin, frmLogin);
  Application.CreateForm(TfrmAcess, frmAcess);
  Application.Run;
end.
