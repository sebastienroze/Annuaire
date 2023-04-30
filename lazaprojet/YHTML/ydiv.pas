unit YDiv;

{$mode objfpc}{$H+}

interface

uses
  YHtmlControl,yView,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;

type

  { TYDiv }

  TYDiv = class(TYHtmlControl)
  private
    fOnClick : TYHtmlEvent;
    fTargetView : TYView;
  protected
    procedure UseControlDesign;override;
  public
    procedure Paint; override;
    function YHTML: string;override;
    procedure SetBounds(aLeft, aTop, aWidth, aHeight: integer); override;
    function Yscript : string; override;
    procedure FillFromRequest(ARequestContent : TStrings; var vOnClick : TYHtmlEvent;var Sender:TObject;YHTMLEXIT : string;var ErrorMessage : string);override;
    procedure PutUseControlWidth(aValue : boolean); override;
  published
    constructor Create(TheOwner: TComponent);override;
    property OnClick: TYHtmlEvent read fOnClick write fOnClick;
    property TargetView : TYView read fTargetView write fTargetView;

    property TabOrder;
  end;

procedure Register;

implementation

uses YServer,YClass,strprocs;

procedure Register;
begin
  {$I ydiv_icon.lrs}
  RegisterComponents('YHTML',[TYDiv]);
end;

{ TYDiv }

procedure TYDiv.UseControlDesign;
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

procedure TYDiv.Paint;
{var
  scolor : string;  }
begin
  inherited Paint;
  if  (csDesigning in ComponentState)  then
  begin
     Canvas.Rectangle(0,0,Width,Height);
  end;
end;

function TYDiv.YHTML: string;
var sonclick : string;
begin
  if Assigned(fOnClick) then sonclick := 'onclick="ydiv_' + Name+'()" '
  else sonclick:= '';

  result := '<div id="id' +Name +'" ' +sonclick + EncodeHtmlClassStyle+'>';
  result := result + Text+ GenereHtml(Self);
  result := result + '</div>';
end;

procedure TYDiv.SetBounds(aLeft, aTop, aWidth, aHeight: integer);
var i : integer;
    LeYCtrl : TYHtmlControl;
begin
  if assigned(Parent) and (csDesigning in ComponentState) and  (not (csLoading in ComponentState)) and (bfrozen = false) then
  begin
     if IdeStyle.position <> TYpAbsolute then
     begin
      if (fUseControlWidth = false) then aWidth := Parent.Width;
      if (fUseControlHeight = false) then
      begin
       aHeight:= 6;
       for i := 0 to ControlCount-1 do
       begin
         if Controls[i] is TYHtmlControl then
         begin
             LeYCtrl := TYHtmlControl(Controls[i]);
             if (aHeight < (LeYCtrl.Top+LeYCtrl.Height)) then aHeight := (LeYCtrl.Top+LeYCtrl.Height);
         end;
       end
      end;
     end;
  end;
  inherited SetBounds(aLeft, aTop, aWidth, aHeight);
end;

function TYDiv.Yscript: string;
var
  myCtrl : TWinControl;
  sTmp : string;
begin
  result := '';
  if Assigned(fOnClick) then
  begin
    result := result +'function ydiv_' + Name+'() {';
    sTmp := 'RefreshMe("div_'+name+':");';
    myCtrl :=  fTargetView;
    if  Assigned(myCtrl) then
    begin
      if myCtrl is TYCustomView  then
      sTmp :=  TYCustomView(myCtrl).JVS_getElementById+'.contentWindow.'+sTmp;
    end;
    result := result +JVS_ParentForm+sTmp;
    result := result +'}';
  end;
end;

procedure TYDiv.FillFromRequest(ARequestContent: TStrings;
  var vOnClick: TYHtmlEvent; var Sender: TObject; YHTMLEXIT: string;
  var ErrorMessage: string);
var stmp : string;
begin
  inherited FillFromRequest(ARequestContent, vOnClick, Sender, YHTMLEXIT,
    ErrorMessage);
  if Assigned(fOnClick) then
  begin
      stmp := StrToken(YHTMLEXIT,':');
      if stmp = ('div_'+name) then
      begin
         vOnClick := TYHtmlEvent(fOnClick);
         Sender := self;
      end;
  end;
end;

procedure TYDiv.PutUseControlWidth(aValue: boolean);
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

constructor TYDiv.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  BrBefore := true;BrAfter := true;
end;

end.
