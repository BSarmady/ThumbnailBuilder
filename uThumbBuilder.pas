unit uThumbBuilder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, RzEdit, Mask, ExtCtrls, RzBtnEdt, RzButton,
  RzLabel, RzPanel, jpeg;

const
  cAppRegistryRoot = 'Software\JGhost\ThumbBuilder\';
  cAppName = 'Thumbnail Builder';

type
  TfmThumbBuilder = class(TForm)
    RzPanel2: TRzPanel;
    lblCaption: TRzLabel;
    RzLabel1: TRzLabel;
    btnStart: TRzButton;
    edtPath: TRzButtonEdit;
    logtext: TRzRichEdit;
    procedure edtPathButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
  private
    Processing:Boolean;

    procedure FindAllFiles(Path: string);
    procedure Log(Msg: string; Color: TColor);
    procedure ResizeImage(ImageFileL, ImageFileS: string);

  public
  end;

var
  fmThumbBuilder: TfmThumbBuilder;

implementation

{$R *.dfm}

uses uRegistry, FileCtrl;

{$region 'procedure TfmThumbBuilder.ResizeImage(ImageFileL:string;ImageFileS:string);'}
// Resize image to smaller size and save to file
procedure TfmThumbBuilder.ResizeImage(ImageFileL:string;ImageFileS:string);
Const
  MAX_THUMB_WIDTH=170;
  MAX_THUMB_HEIGHT= ROUND(MAX_THUMB_WIDTH * 3/4);
var
  JPEGImage: TJPEGImage;
  Bitmap:  TBitmap;
  NewWidth,
  NewHeight: Integer;
begin
  Log('  ' + ExtractFileName(ImageFileL), clblack);
  if not FileExists(ImageFileL) then
    Exit;
  JPEGImage := TJPEGImage.Create;
  Bitmap  := TBitmap.Create;
  try
    JPEGImage.LoadFromFile(ImageFileL);
    Bitmap.Assign(JPEGImage);
    if (Bitmap.Width <= MAX_THUMB_WIDTH) and (Bitmap.Height<=MAX_THUMB_HEIGHT) then begin
      //if src image smaller than destination image nothing to do
      NewWidth := Bitmap.Width;
      NewHeight := Bitmap.Height;
    end else if MAX_THUMB_WIDTH/MAX_THUMB_HEIGHT>Bitmap.Width/Bitmap.Height then begin
      //Resize Image width to fit available screen
      NewWidth  := Round(MAX_THUMB_HEIGHT*Bitmap.Width/Bitmap.Height);
      NewHeight := MAX_THUMB_HEIGHT;
    end else begin
      //Resize Image Height to fit available screen
      NewWidth  := MAX_THUMB_WIDTH;
      NewHeight := Round(MAX_THUMB_WIDTH*Bitmap.Height/Bitmap.Width);
    end;

    // Draw resized image back to same canvas to save memory
    Bitmap.Canvas.StretchDraw(Rect(0,0,NewWidth,NewHeight),Bitmap);

    // Resize canvas to fit new resized image
    Bitmap.Width:=NewWidth;
    Bitmap.Height:=NewHeight;

    //Convert to jpeg and save
    JPEGImage.CompressionQuality:= 90;
    JPEGImage.Assign(Bitmap);
    if not DirectoryExists(ExtractFilePath(ImageFileS)) then
      ForceDirectories(ExtractFilePath(ImageFileS));
    JPEGImage.SaveToFile(ImageFileS);
  finally
    JPEGImage.Free;
    Bitmap.Free;
  end;
end;
{$endregion}

{$region 'procedure TfmThumbBuilder.FormCreate(Sender: TObject);'}
procedure TfmThumbBuilder.FormCreate(Sender: TObject);
begin
  Processing:=False;
  Caption:=cAppName;
  lblCaption.Caption:=cAppName;
  Application.Title:= cAppName;

  LoadFormState(Self,cAppRegistryRoot);
  edtPath.Text:=LoadFromRegistry(cAppRegistryRoot,'LastFolder',ExtractFilePath(Application.ExeName));

end;
{$endregion}

{$region 'procedure TfmThumbBuilder.FormClose(Sender: TObject; var Action: TCloseAction);'}
procedure TfmThumbBuilder.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFormState(Self,cAppRegistryRoot);
  SaveToRegistry(cAppRegistryRoot,'LastFolder',edtPath.Text);
end;
{$endregion}

{$region 'procedure TfmThumbBuilder.Log(Msg: string; Color:TColor);'}
procedure TfmThumbBuilder.Log(Msg: string; Color:TColor);
begin
  LogText.SelAttributes.Color:=Color;
  LogText.Lines.Add(Msg);
  LogText.SelStart := Length(LogText.Text);
  LogText.Perform(EM_SCROLLCARET, 0, 0);
end;
{$endregion}

{$region 'procedure TfmThumbBuilder.edtPathButtonClick(Sender: TObject);'}
procedure TfmThumbBuilder.edtPathButtonClick(Sender: TObject);
var
  Directory:string;
begin
  if Processing then
    Exit;
  Directory:=edtPath.text;
  if SelectDirectory('Select Images Folder','',Directory,[sdNewFolder,sdShowShares, sdNewUI, sdValidateDir]) then
    edtPath.Text:=Directory;
end;
{$endregion}

{$region 'procedure TfmThumbBuilder.btnStartClick(Sender: TObject);'}
procedure TfmThumbBuilder.btnStartClick(Sender: TObject);
begin
  if not Processing then begin
    logtext.Clear;
    Processing:=True;
    logtext.SetFocus;
    btnStart.Caption:='Stop';
    edtPath.Enabled:=False;
    edtPath.Text := IncludeTrailingBackslash(edtPath.Text);
    FindAllFiles(edtPath.Text);
    if Processing then
      Log('Scan Complete', clPurple);
    Processing:=False;
    btnStart.Caption:='Start';
    edtPath.Enabled:=True;
  end else begin
    Processing:=False;
    Log('Error:Cancelled by user',clRed);
    btnStart.Caption:='Start';
  end;

end;
{$endregion}

{$region 'procedure TfmThumbBuilder.FindAllFiles(Path:string);'}
procedure TfmThumbBuilder.FindAllFiles(Path:string);
var
 SearchRec:TSearchRec;
 ThumbPath:string;
begin
  try
    Log(Path, clblue);
    if FindFirst(IncludeTrailingBackslash(Path) + '*.*', faAnyFile, SearchRec) = 0 then begin
      repeat
        if not Processing then
          exit;
        if (SearchRec.Attr and faDirectory) = faDirectory then begin
          if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') and (LowerCase(SearchRec.Name)<>'s')  then begin
            FindAllFiles(Path  + SearchRec.Name + '\');
          end;
        end else if LowerCase(ExtractFileExt(SearchRec.Name)) = '.jpg' then begin
          ThumbPath:= StringReplace(Path,edtPath.Text, edtPath.Text + 's\',[]);
          if not FileExists(ThumbPath + SearchRec.Name) then
            ResizeImage(Path + SearchRec.Name, ThumbPath + SearchRec.Name);
        end;
        Application.ProcessMessages;
      until FindNext(SearchRec) <> 0;
      FindClose(SearchRec);
    end;
  except
    on ex:Exception do begin
      Log('  Error:' + ex.Message,clRed);
    end;
  end;
end;
{$endregion}

end.


