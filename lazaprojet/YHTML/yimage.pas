unit YImage;

{$mode objfpc}{$H+}

interface

uses
  YHtmlControl,extctrls,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;

type

  { TYImage }

  TYImage = class(TYHtmlControl)
  private
     MyImage : TImage;
     fIDEPreviewFile : string;
  protected
    procedure SetIDEPreviewFile(AValue: string);
  public
    function YHTML: string;override;
    function JVS_SelectInContext : string;
    function JVS_DrawImage(ImageX,ImageY,ImageWidth,ImageHeight,CanvasX,CanvasY,CanvasWidth,CanvasHeight : integer) : string;
  published
    constructor Create(TheOwner: TComponent);override;
    procedure Paint; override;
    property IDEPreviewFile : string read fIDEPreviewFile write SetIDEPreviewFile;

  end;

procedure Register;

implementation


procedure Register;
begin
  {$I yimage_icon.lrs}
  RegisterComponents('YHTML',[TYImage]);
end;

{ TYImage }

procedure TYImage.SetIDEPreviewFile(AValue: string);
begin
  fIDEPreviewFile := AValue;
  if fIDEPreviewFile<> '' then
  begin
    if (csDesigning in ComponentState) then
    if FileExists(fIDEPreviewFile) then
    MyImage.Picture.LoadFromFile(fIDEPreviewFile);
  end
  else MyImage.Picture.Clear;
end;

function TYImage.YHTML: string;
begin
  result := '<img src="'+CYURIFile+'/'+ text + '" id="id' +Name +'" ' + EncodeHtmlClassStyle+'>'
end;

function TYImage.JVS_SelectInContext: string;
begin
  result := 'yimg'+Name+' = parent.document.getElementById("id'+Name+'");';
end;

function TYImage.JVS_DrawImage(ImageX, ImageY, ImageWidth, ImageHeight,
  CanvasX, CanvasY, CanvasWidth, CanvasHeight: integer): string;
begin
  result := 'y_ctx.drawImage(yimg'+Name+','+
  IntToStr(ImageX)+','+IntToStr(ImageY)+','+
  IntToStr(ImageWidth)+','+IntToStr(ImageHeight)+','+
  IntToStr(CanvasX)+','+IntToStr(CanvasY)+','+
  IntToStr(CanvasWidth)+','+IntToStr(CanvasHeight)+');';
end;

constructor TYImage.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  if (csDesigning in ComponentState) then
  begin
    MyImage:= TImage.Create(self);
    MyImage.Parent := self;
    MyImage.AutoSize := true;
    MyImage.Stretch:= true;
    MyImage.Align:= alClient;
  end;


end;

procedure TYImage.Paint;
begin
  if (csDesigning in ComponentState) and (not (csLoading in ComponentState))then
  begin
{    Canvas.pen.Color:=clOlive;
    Canvas.Brush.Color:=clOlive;
    Canvas.FillRect(0,0,Width,Height);  }
{    try
    if Text<> '' then
    begin
      with TImage.Create(self) do
      begin
          Picture.LoadFromFile('D:\lazaprojet\test2\files\'+ Text);
          Self.Canvas.Draw(0,0,Picture.Graphic);
          free;
      end;
    end;
    except
    end;
        }
  end;
  inherited Paint;
end;

end.
