unit YText;

{$mode objfpc}{$H+}

interface

uses
  YHtmlControl,YClass,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;

type

  { TYText }

  TYText = class(TYHtmlControl)
  private
  protected
    procedure SetfText(AValue: string);override;
    procedure UseControlDesign;override;
  public
    constructor Create(TheOwner: TComponent);override;
    procedure Paint; override;
    procedure SetBounds(aLeft, aTop, aWidth, aHeight: integer); override;
    procedure PutUseControlWidth(aValue : boolean); override;
    function YHTML: string;override;
  published
  end;

procedure Register;

implementation

procedure Register;
begin
  {$I ytext_icon.lrs}
  RegisterComponents('YHTML',[TYText]);
end;

{ TYText }

procedure TYText.SetfText(AValue: string);
begin
  fText:= AValue;
  if (csDesigning in ComponentState) and  (not (csLoading in ComponentState)) then
  begin
    SetBounds(Left,Top,Width,Height);
  end;
end;

constructor TYText.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
end;

procedure TYText.Paint;
var sFontname : string;
begin
  inherited Paint;
  if  (csDesigning in ComponentState) and (fText<> '') then
  begin
    sFontname := IdeStyle.font_family;
    if sFontname = '' then sFontname := 'Times New Roman';
    Canvas.Font.Name := sFontname;
    if (Canvas.Font.Size <> IdeStyle.font_size) then SetBounds(Left,Top,Width,Height);
    Canvas.Font.Style:= IdeStyle.font_style;
    Canvas.TextOut(0,0,fText);
  end;
end;

procedure TYText.SetBounds(aLeft, aTop, aWidth, aHeight: integer);
var sFontname : string;
begin
  if (csDesigning in ComponentState) and  (not (csLoading in ComponentState)) then
  begin
    if (fText<> '') then
    begin
      Canvas.Font.Size:= IdeStyle.font_size;
      sFontname := IdeStyle.font_family;
      if sFontname = '' then sFontname := 'Times New Roman';
      Canvas.Font.Name := sFontname;
      Canvas.Font.Style:= IdeStyle.font_style;
      if (fUseControlHeight = false) then aHeight := Canvas.TextHeight (fText);
      if (fUseControlWidth = false) then aWidth := Canvas.TextWidth(fText);
    end;
    if aHeight = 0 then aHeight:= 10;
    if aWidth = 0 then aWidth:= 3;
  end;
  inherited SetBounds(aLeft, aTop, aWidth, aHeight);
end;

procedure TYText.PutUseControlWidth(aValue: boolean);
begin
  if aValue <> fUseControlWidth then
  begin
    inherited PutUseControlWidth(aValue);
    if (aValue = false) then
    begin
      HtmlStyle.display := TYdNONE;
    end;
  end;
end;

procedure TYText.UseControlDesign;
begin
  inherited UseControlDesign;
  if (fUseControlWidth = true) then
  begin
    HtmlStyle.display := TYdInline_Block
  end
  else
  begin
    if HtmlStyle.display = TYdInline_Block then HtmlStyle.display := TYdNONE;
  end;
end;


function TYText.YHTML: string;
var sclassStyle : string;
begin
  sclassStyle :=  EncodeHtmlClassStyle;
  if (sclassStyle <> '' ) then
  begin
    Result := '<span id="id' +Name +'" ' + sclassStyle+ '>'+Text + '</span>'
  end
  else result := Text;
end;

end.
