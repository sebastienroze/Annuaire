unit YCanvas;

{$mode objfpc}{$H+}

interface

uses
  YHtmlControl,YImage,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;

type

  { TYCanvas }

  TYCanvas = class(TYHtmlControl)
  private
    fCanvasWidth,fCanvasHeight : integer;
  protected

  public
    procedure Paint; override;
    function YHTML: string;override;
  published
    property CanvasWidth : Integer read fCanvasWidth write fCanvasWidth;
    property CanvasHeight : Integer read fCanvasHeight write fCanvasHeight;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$I ycanvas_icon.lrs}
  RegisterComponents('YHTML',[TYCanvas]);
end;

{ TYCanvas }

procedure TYCanvas.Paint;
begin
  inherited Paint;
  if  (csDesigning in ComponentState)  then
  begin
     Canvas.Pen.Style := psDashDotDot;
     Canvas.Rectangle(0,0,Width,Height);
  end;
end;

function TYCanvas.YHTML: string;
begin
  result := '<canvas id="id' +Name +'" width="'+IntToStr(fCanvasWidth)+'" height="'+IntToStr(fCanvasHeight)+'" ' + EncodeHtmlClassStyle+'>HTML5 canvas</canvas>'
end;


end.
