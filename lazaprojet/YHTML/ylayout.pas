unit YLayout;

{$mode objfpc}{$H+}

interface

uses
  YHtmlControl,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;

type

  { TYLayout }

  TYLayout = class(TYCustomLayout)
  private
    fMargin : integer;
    fScale : integer;
  protected

  public
    constructor Create(TheOwner: TComponent);override;
    function YScript_browserResize : string;override;
  published
    property Margin : integer read fMargin write fMargin;
    property Scale : integer read fScale write fScale;
  end;


procedure Register;

implementation

//uses strutils;

procedure Register;
begin
  {$I ylayout_icon.lrs}
  RegisterComponents('YHTML',[TYLayout]);
end;


function LinkToStr(LeLink : TYLink) : string;
begin
  Result :='';
  case LeLink of
    TYlLEFT : Result := 'left';
    TYlRight : Result := 'right';
    TYlTop : Result := 'top';
    TYlBottom : Result := 'bottom';
    TYlWidth : Result := 'width';
    TYlHeight : Result := 'height';
  end;
end;

function ParcourLayoutComposants(Cpn : TComponent;LeLayout : TYLayout) : string;
var i : integer;
  LeYControl : TYHtmlControl;
  YViewRequired : string;
  smarge,sscale : string;
//  sparent : string;
begin
  if LeLayout.fMargin <> 0 then smarge:= IntToStr(LeLayout.fMargin)+'+' else smarge:= '';
  if LeLayout.fScale <> 0 then sscale:= IntToStr(LeLayout.fScale)+'+' else sscale:= '';
  result := '';
  YViewRequired := '';
    for i := 0 to Cpn.ComponentCount -1 do
    begin
        result := result +ParcourLayoutComposants(Cpn.Components[i],LeLayout);

        if Cpn.Components[i] is TYHtmlControl then
        begin
          LeYControl := TYHtmlControl(Cpn.Components[i]) ;
          if LeYControl.Layout = LeLayout then
          begin
            if Assigned(LeLayout.AlignLeft) then
               result := result +JVS_SetCoord(LeYControl,'left',smarge+'window.pageXOffset+'+JVS_GetCoord(LeLayout.AlignLeft,LinkToStr(LeLayout.LinkLeft),YViewRequired),YViewRequired);
            if Assigned(LeLayout.AlignTop) then
               result := result +JVS_SetCoord(LeYControl,'top',smarge+'window.pageYOffset+'+JVS_GetCoord(LeLayout.AlignTop,LinkToStr(LeLayout.LinkTop),YViewRequired),YViewRequired);
            if Assigned(LeLayout.AlignRight) then
               result := result +JVS_SetCoord(LeYControl,'right',smarge+'window.innerWidth-'+JVS_GetCoord(LeLayout.AlignRight,LinkToStr(LeLayout.LinkRight),YViewRequired),YViewRequired);
            if Assigned(LeLayout.AlignBottom) then
               result := result +JVS_SetCoord(LeYControl,'bottom',smarge+'window.innerHeight-'+JVS_GetCoord(LeLayout.AlignBottom,LinkToStr(LeLayout.LinkBottom),YViewRequired),YViewRequired);
            if Assigned(LeLayout.AlignHeight) then
               result := result +JVS_SetCoord(LeYControl,'height',sscale+JVS_GetCoord(LeLayout.AlignHeight,LinkToStr(LeLayout.LinkHeight),YViewRequired),YViewRequired);
            if Assigned(LeLayout.AlignWidth) then
               result := result +JVS_SetCoord(LeYControl,'width',sscale+JVS_GetCoord(LeLayout.AlignWidth,LinkToStr(LeLayout.LinkWidth),YViewRequired),YViewRequired);
          end;
        end;
    end;
    if YViewRequired <> '' then
    begin
//      sparent := '';
//      if Cpn is TYHtmlControl then sparent:=TYHtmlControl(cpn).JVS_ParentForm ;
//      if sparent <> '' then YViewRequired := StringReplace(YViewRequired,'(','('+sparent,[rfReplaceAll]);
      result := 'if ('+YViewRequired+') {'+result +'}';
    end;
end;

{ TYLayout }

constructor TYLayout.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  LinkLeft:= TYlLEFT;
  LinkTop:= TYlTop;
  LinkRight:= TYlRight;
  LinkBottom:= TYlBottom;
  LinkHeight:= TYlHeight;
  LinkWidth:= TYlWidth;
  fMargin := 0;
end;

function TYLayout.YScript_browserResize: string;
var
  WinParent : TForm;
  LeCpn : TComponent ;
begin
  LeCpn := Owner;
  while assigned(LeCpn) and not (LeCpn is TForm) do
  begin
    LeCpn := LeCpn.Owner;
  end;
  if LeCpn is  TForm then
  begin
    WinParent := TForm(LeCpn);
    result := ParcourLayoutComposants(WinParent,Self);
  end;
end;

end.
