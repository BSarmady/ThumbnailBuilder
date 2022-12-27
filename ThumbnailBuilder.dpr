program ThumbnailBuilder;

uses
  Forms,
  uThumbBuilder in 'uThumbBuilder.pas' {fmThumbBuilder};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'ID3 v1 Tag Remover';
  Application.CreateForm(TfmThumbBuilder, fmThumbBuilder);
  Application.Run;
end.
