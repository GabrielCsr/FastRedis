object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 230
  ClientWidth = 523
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Edit1: TEdit
    Left = 8
    Top = 8
    Width = 201
    Height = 23
    TabOrder = 0
    Text = 'Channel'
    TextHint = 'Channel'
  end
  object Memo1: TMemo
    Left = 8
    Top = 37
    Width = 201
    Height = 156
    Enabled = False
    TabOrder = 1
  end
  object btnSubscribe: TButton
    Left = 215
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Subscribe'
    TabOrder = 2
    OnClick = btnSubscribeClick
  end
  object Memo2: TMemo
    Left = 312
    Top = 37
    Width = 201
    Height = 156
    TabOrder = 3
  end
  object Edit2: TEdit
    Left = 312
    Top = 8
    Width = 201
    Height = 23
    TabOrder = 4
    Text = 'Channel'
    TextHint = 'Channel'
  end
  object btnPublish: TButton
    Left = 438
    Top = 199
    Width = 75
    Height = 25
    Caption = 'Publish'
    TabOrder = 5
    OnClick = btnPublishClick
  end
  object Button1: TButton
    Left = 215
    Top = 39
    Width = 75
    Height = 25
    Caption = 'UnSubscribe'
    TabOrder = 6
    OnClick = Button1Click
  end
end
