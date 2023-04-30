unit YBr;

{$mode objfpc}{$H+}

interface

uses
  YHtmlControl,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;

type

  { TYBr }

  TYBr = class(TYHtmlControl)
  private

  protected

  public
    procedure Paint; override;
    procedure SetBounds(aLeft, aTop, aWidth, aHeight: integer); override;
    function YHTML: string;override;
  published
    constructor Create(TheOwner: TComponent);override;

  end;

procedure Register;

implementation

procedure Register;
begin
  {$I ybr_icon.lrs}
  RegisterComponents('YHTML',[TYBr]);
end;

{ TYBr }

procedure TYBr.Paint;
begin
  inherited Paint;
  if  (csDesigning in ComponentState)  then
  begin
    Canvas.Rectangle(0,0,Width,Height);
    Canvas.Line(2,6,9,6);
    Canvas.Line(2,6,5,3);
    Canvas.Line(2,6,5,9);
    Canvas.Line(9,6,9,3);
  end;
end;

procedure TYBr.SetBounds(aLeft, aTop, aWidth, aHeight: integer);
begin
  if  (csDesigning in ComponentState)  then
  begin
    aHeight := 12;
    aWidth := 12;
  end;
  inherited SetBounds(aLeft, aTop, aWidth, aHeight);
end;

function TYBr.YHTML: string;
begin
  result := '<br id="id'+Self.Name+'">';
end;

constructor TYBr.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  BrBefore := false;BrAfter := true;
end;

end.
