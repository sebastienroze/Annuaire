unit YSound;

{$mode objfpc}{$H+}

interface

uses
  YHtmlControl,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;

type

  { TYSound }

  TYSound = class(TYHtmlControl)
  private
//     fSoundFile : string;
     fAutoplay : boolean;
     fControls: boolean;
  protected

  public
    procedure Paint; override;
    procedure SetBounds(aLeft, aTop, aWidth, aHeight: integer); override;
    function YHTML: string;override;

  published
//    property SoundFile : string read fSoundFile write fSoundFile;
    property Autoplay : boolean read fAutoplay write fAutoplay;
    property Controls : boolean read fControls write fControls;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$I ysound_icon.lrs}
  RegisterComponents('YHTML',[TYSound]);
end;

{ TYSound }

procedure TYSound.Paint;
begin
  inherited Paint;
  if  (csDesigning in ComponentState)  then
  begin
    Canvas.Pen.Color:= clBlack;
    Canvas.Brush.Color:= clBlack;
    Canvas.Rectangle(0,0,Width,Height);
    Canvas.Pen.Color:= clWhite;
    Canvas.Pen.Width:= 3;
    Canvas.MoveTo(2,2);
    Canvas.LineTo(Width div 10, Height div 2);
    Canvas.LineTo(2,Height -2);
    Canvas.LineTo(2,2);
    if (fText<> '') then
    begin
      Canvas.Font.Color:= clWhite;
      Canvas.TextOut(2+(Width div 10),2,ftext);//
    end;
  end;
end;

procedure TYSound.SetBounds(aLeft, aTop, aWidth, aHeight: integer);
begin
  if (csDesigning in ComponentState) and  (not (csLoading in ComponentState)) then
  begin
      if (fUseControlHeight = false) then aHeight := 30;
      if (fUseControlWidth = false) then
      begin
        if Controls = true then aWidth := 300 else aWidth := 100;
      end;
  end;
  inherited SetBounds(aLeft, aTop, aWidth, aHeight);
end;

function TYSound.YHTML: string;
var sSoundType : string;
begin
  sSoundType:= LowerCase(ExtractFileExt(fText));
  system.Delete(sSoundType,1,1);
  if sSoundType = 'mp3' then sSoundType:= 'mpeg';
  result := '<audio ';
  if fAutoplay = true then Result := Result + 'autoplay ';
  if fControls = true then Result := Result + 'controls ';
  result := result + 'name="' +Name + '"  id="id' +Name + '" '+ EncodeHtmlClassStyle+'>';
  Result := Result + '<source src="'+CYURIFile+'/'+ text+'" type="audio/'+ sSoundType+'"></audio>';
end;

end.
