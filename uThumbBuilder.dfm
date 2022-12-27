object fmThumbBuilder: TfmThumbBuilder
  Left = 222
  Top = 160
  Caption = 'fmThumbBuilder'
  ClientHeight = 221
  ClientWidth = 438
  Color = clBtnFace
  Font.Charset = ARABIC_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 14
  object RzPanel2: TRzPanel
    Left = 0
    Top = 0
    Width = 438
    Height = 89
    Align = alTop
    BorderOuter = fsGroove
    Color = 15987699
    TabOrder = 0
    ExplicitWidth = 434
    DesignSize = (
      438
      89)
    object lblCaption: TRzLabel
      Left = 8
      Top = 8
      Width = 116
      Height = 30
      Caption = 'lblCaption'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Arial Black'
      Font.Style = []
      ParentFont = False
    end
    object RzLabel1: TRzLabel
      Left = 8
      Top = 40
      Width = 76
      Height = 14
      Caption = 'Images Folder'
    end
    object btnStart: TRzButton
      Left = 372
      Top = 56
      Width = 57
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'Start'
      HotTrack = True
      TabOrder = 0
      OnClick = btnStartClick
    end
    object edtPath: TRzButtonEdit
      Left = 8
      Top = 56
      Width = 353
      Height = 22
      Text = ''
      Anchors = [akLeft, akTop, akRight]
      FrameVisible = True
      TabOrder = 1
      AltBtnNumGlyphs = 1
      ButtonNumGlyphs = 1
      FlatButtons = True
      OnButtonClick = edtPathButtonClick
    end
  end
  object logtext: TRzRichEdit
    Left = 0
    Top = 89
    Width = 438
    Height = 132
    Align = alClient
    Color = clInfoBk
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
    FrameVisible = True
    ExplicitWidth = 434
    ExplicitHeight = 131
  end
end
