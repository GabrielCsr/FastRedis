unit View;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Skia,
  FMX.Ani, FMX.Objects, FMX.Skia, FMX.Layouts, FMX.Controls.Presentation,
  FMX.StdCtrls, System.Math.Vectors, FMX.Controls3D, FMX.Layers3D, FMX.Edit;

type
  TfrmLogin = class(TForm)
    layCircle: TLayout;
    SkSvg1: TSkSvg;
    Circle: TCircle;
    AnimationCircle: TFloatAnimation;
    layLogin: TLayout;
    layLoginFields: TLayout;
    layLoginText: TLayout;
    Layout1: TLayout;
    SkLabel1: TSkLabel;
    SkLabel2: TSkLabel;
    btnToCreateAccount: TRoundRect;
    SkLabel3: TSkLabel;
    Layout2: TLayout;
    lblLogin: TSkLabel;
    RecEdtUser: TRoundRect;
    edtUser: TEdit;
    RecEdtPassword: TRoundRect;
    edtPasswordLogin: TEdit;
    RoundRect1: TRoundRect;
    SkLabel4: TSkLabel;
    layAccount: TLayout;
    layAccountFields: TLayout;
    Layout4: TLayout;
    SkLabel5: TSkLabel;
    RoundRect2: TRoundRect;
    edtUserCreateAccount: TEdit;
    RoundRect10: TRoundRect;
    edtPasswordCreateAccount: TEdit;
    btnCreateAccount: TRoundRect;
    SkLabel6: TSkLabel;
    layAccountText: TLayout;
    Layout5: TLayout;
    SkLabel7: TSkLabel;
    SkLabel8: TSkLabel;
    btnToLogin: TRoundRect;
    SkLabel9: TSkLabel;
    lblUserExists: TSkLabel;
    Layout3: TLayout;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure AnimationCircleFinish(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnToLoginClick(Sender: TObject);
    procedure btnCreateAccountClick(Sender: TObject);
    procedure edtUserCreateAccountExit(Sender: TObject);
    procedure RoundRect1Click(Sender: TObject);
  private
    procedure SetupObjects;
    procedure Animate;
    procedure Acess;
  public
  end;

var
  frmLogin: TfrmLogin;

implementation

uses
  FastRedis, Account.Entity, Acess;

{$R *.fmx}

procedure TfrmLogin.Acess;
begin
  var LAcessForm := TFrmAcess.Create(Self);
  try
    LAcessForm.User := edtUser.Text;
    LAcessForm.Key := 'AccountAcess:' + LAcessForm.User;

    TFastRedis.Save(LAcessForm.Key, 'acesso', 10000);
    LAcessForm.ShowModal;
    ShowMessage('Tempo de acesso expirado, refaça o login.');
  finally
    LAcessForm.Free;
  end;
end;

procedure TfrmLogin.Animate;
begin
  if AnimationCircle.Inverse then
    TAnimator.AnimateFloat(layAccount, 'Opacity', 0, 0.3)
  else
    TAnimator.AnimateFloat(layLogin, 'Opacity', 0, 0.3);

  AnimationCircle.Start;
end;

{ TForm1 }

procedure TfrmLogin.AnimationCircleFinish(Sender: TObject);
begin
  layLogin.Visible := AnimationCircle.Inverse;
  layAccount.Visible := not AnimationCircle.Inverse;

  if AnimationCircle.Inverse then
    TAnimator.AnimateFloat(layLogin, 'Opacity', 1, 0.5)
  else
    TAnimator.AnimateFloat(layAccount, 'Opacity', 1, 0.5);

  AnimationCircle.Inverse := not AnimationCircle.Inverse;
end;

procedure TfrmLogin.btnToLoginClick(Sender: TObject);
begin
  Animate;
end;

procedure TfrmLogin.Button1Click(Sender: TObject);
begin
  Animate;
end;

procedure TfrmLogin.edtUserCreateAccountExit(Sender: TObject);
var
  LUserExists: Boolean;
begin
  if edtUserCreateAccount.Text = '' then
    Exit;

  LUserExists := TFastRedis.Hash.Exists<TAccount>('Account:' + edtUserCreateAccount.Text);

  lblUserExists.Visible := LUserExists;
  btnCreateAccount.Enabled := not LUserExists;
end;

procedure TfrmLogin.FormResize(Sender: TObject);
begin
  SetupObjects;
end;

procedure TfrmLogin.FormShow(Sender: TObject);
begin
  SetupObjects;
  lblUserExists.Visible := False;
end;

procedure TfrmLogin.RoundRect1Click(Sender: TObject);
begin
  if edtUser.Text.IsEmpty then
  begin
    ShowMessage('Usuário não informado');
    Exit;
  end;

  if edtPasswordLogin.Text.IsEmpty then
  begin
    Exit;
    ShowMessage('Senha não infomada');
  end;

  if not TFastRedis.Hash.Exists<TAccount>('Account:' + edtUser.Text) then
  begin
    ShowMessage('Senha ou Usuário incorreto!');
    Exit;
  end;

  var LAccont :=  TFastRedis.Hash.Load<TAccount>('Account:' + edtUser.Text);
  try
    if not LAccont.Password.Equals(edtPasswordLogin.Text) then
    begin
      ShowMessage('Senha ou Usuário incorreto!');
      Exit;
    end;
    Acess;
  finally
    LAccont.Free;
  end;
end;

procedure TfrmLogin.btnCreateAccountClick(Sender: TObject);
var
  LAccount: TAccount;
begin
  LAccount := TAccount.Create;
  try
    LAccount.User     := Trim(edtUserCreateAccount.Text);
    LAccount.Password := edtPasswordCreateAccount.Text;

    TFastRedis.Hash.Save<TAccount>('Account:' + LAccount.User, LAccount);
    ShowMessage('Usuário registrado com sucesso. Faça login em sua nova conta.');
    Animate;
  finally
    LAccount.Free;
  end;
end;

procedure TfrmLogin.SetupObjects;
begin
  if layCircle.Width >= layCircle.Height then
  begin
    Circle.Width  := layCircle.Width * 1.5;
    Circle.Height := Circle.Width;
    Circle.Margins.Bottom := Circle.Width * 0.3;

    AnimationCircle.PropertyName := 'Margins.Right';
    AnimationCircle.StartValue   := Circle.Width * 0.8;
    AnimationCircle.StopValue    := -AnimationCircle.StartValue;

    if AnimationCircle.Inverse then
      Circle.Margins.Right := AnimationCircle.StopValue
    else
      Circle.Margins.Right := AnimationCircle.StartValue;

    layLoginText.Align := TAlignLayout.Left;
    layLoginText.Width := layCircle.Width / 2;

    layLoginFields.Width := layLoginText.Width;
    layLoginFields.Align := TAlignLayout.Right;

    layAccountText.Align := TAlignLayout.MostRight;
    layAccountText.Width := layCircle.Width / 2;

    layAccountFields.Width := layLoginText.Width;
    layAccountFields.Align := TAlignLayout.MostLeft;
  end
  else
  begin
    Circle.Height  := layCircle.Height * 1.5;
    Circle.Width := Circle.Height;
    Circle.Margins.Right := 0;

    AnimationCircle.PropertyName := 'Margins.Bottom';
    AnimationCircle.StartValue   := Circle.Width * 0.95;
    AnimationCircle.StopValue    := -AnimationCircle.StartValue;

    if AnimationCircle.Inverse then
      Circle.Margins.Bottom := AnimationCircle.StopValue
    else
      Circle.Margins.Bottom := AnimationCircle.StartValue;

    layLoginText.Align := TAlignLayout.Top;
    layLoginText.Height := layCircle.Height / 2;

    layLoginFields.Align := TAlignLayout.Client;

    layAccountText.Align := TAlignLayout.Bottom;
    layAccountText.Height := layCircle.Height / 2;

    layAccountFields.Align := TAlignLayout.Client;
  end;
end;

end.
