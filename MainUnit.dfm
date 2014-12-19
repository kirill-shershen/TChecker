object CallerForm: TCallerForm
  Left = 365
  Top = 247
  BorderStyle = bsDialog
  Caption = 'CloudZap Caller'
  ClientHeight = 236
  ClientWidth = 485
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lPhone: TLabel
    Left = 16
    Top = 16
    Width = 99
    Height = 13
    Caption = 'Enter phone number:'
  end
  object ePhone: TEdit
    Left = 16
    Top = 32
    Width = 297
    Height = 21
    TabOrder = 0
  end
  object bExecute: TButton
    Left = 320
    Top = 28
    Width = 75
    Height = 25
    Caption = 'Call'
    TabOrder = 1
    OnClick = bExecuteClick
  end
  object log: TMemo
    Left = 16
    Top = 64
    Width = 459
    Height = 161
    BevelInner = bvNone
    BevelOuter = bvNone
    Color = clBtnFace
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object bStop: TButton
    Left = 400
    Top = 28
    Width = 75
    Height = 25
    Caption = 'Stop'
    TabOrder = 3
    OnClick = bStopClick
  end
end
