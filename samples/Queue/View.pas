unit View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, FastRedis,
  FastRedisQueue;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Memo1: TMemo;
    btnSubscribe: TButton;
    Memo2: TMemo;
    Edit2: TEdit;
    btnPublish: TButton;
    Button1: TButton;
    procedure btnSubscribeClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnPublishClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FRedisQueue: TFastRedisQueue;
    procedure CallBack(AMessage: String);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnSubscribeClick(Sender: TObject);
begin
  FRedisQueue.Subscribe(Edit1.Text, CallBack);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  FRedisQueue.Unsubscribe(Edit1.Text);
end;

procedure TForm1.btnPublishClick(Sender: TObject);
begin
  FRedisQueue.Publish(Edit2.Text, Memo2.Text);
end;

procedure TForm1.CallBack(AMessage: String);
begin
  Memo1.Lines.Add(AMessage);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FRedisQueue := TFastRedis.Queue;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FRedisQueue.Free;
end;

end.
