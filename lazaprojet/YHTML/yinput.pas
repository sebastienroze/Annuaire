unit YInput;

{$mode objfpc}{$H+}

interface

uses
  YHtmlControl,yView,YDbGrid,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;

type

  { TYInput }

  TYInputType = (TYitText, TYitPassword, TYitNumber);

  TYInput = class(TYHtmlControl)
  private
    procedure SetUpperCase(AValue: boolean);

  protected
    fOnChange : TYHtmlEvent;
    fOnEditingDone : TYHtmlEvent;
    fOnInput : TYHtmlEvent;
    fTargetView : TYView;
//    fTypePassword : Boolean;
    fReadOnly : Boolean;
    fUpperCase : Boolean;
    fTargetGrid : TYDbGrid;
    fInputType: TYInputType;
    fValueMin,fValueMax,fValueStep : string;
    function GetfText: string; override;
  public
    procedure Paint; override;
    procedure SetBounds(aLeft, aTop, aWidth, aHeight: integer); override;
    function YHTML: string;override;
    function Yscript : string; override;
    procedure FillFromRequest(ARequestContent : TStrings; var vOnClick : TYHtmlEvent;var Sender:TObject;YHTMLEXIT : string;var ErrorMessage : string);override;
    function Yscript_keydown: string; override;
  published
    constructor Create(TheOwner: TComponent);override;
    property OnChange : TYHtmlEvent read fOnChange write fOnChange;
    property OnEditingDone : TYHtmlEvent read fOnEditingDone write fOnEditingDone;
    property TargetView : TYView read fTargetView write fTargetView;
    property TargetGrid : TYDbGrid read fTargetGrid write fTargetGrid;
//    property TypePassword : boolean read fTypePassword write fTypePassword;
    property InputType : TYInputType read fInputType write fInputType;
    property ReadOnly : boolean read fReadOnly write fReadOnly;
    property ForceUpperCase : boolean read fUpperCase write SetUpperCase;
    property ValueMin : string read fValueMin write fValueMin;
    property ValueMax : string read fValueMax write fValueMax;
    property ValueStep : string read fValueStep write fValueStep;

    property TabStop;
  end;

procedure Register;

implementation

uses strprocs,YClass,strutils;
procedure Register;
begin
  {$I yinput_icon.lrs}
  RegisterComponents('YHTML',[TYInput]);
end;

{ TYInput }

constructor TYInput.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  FocusEnabled := true;
  UseFocusKeys := true;
  if (csDesigning in ComponentState)  then
  begin
    Height:= 23;
//    fTypePassword := false;
    fHtmlStyle.Margin := '2px';
  end;
end;

procedure TYInput.SetUpperCase(AValue: boolean);
begin
  if fUpperCase=AValue then Exit;
  fUpperCase:=AValue;
  if  (csDesigning in ComponentState)  then
  begin
    if fUpperCase = true then HtmlStyle.text_transform:= TYttUppercase else HtmlStyle.text_transform:= TYttNONE;
  end;
end;

function TYInput.GetfText: string;
begin
  Result:=inherited GetfText;
  if fUpperCase = true then Result := UpperCase(Result);
end;

procedure TYInput.Paint;
var
  sFontname : string;
  txt : string;
begin
  inherited Paint;
  if  (csDesigning in ComponentState)  then
  begin
    Canvas.Pen.Color:= clBlack;
    Canvas.Brush.Color:= clWhite;
    Canvas.Rectangle(0,0,Width,Height);
    if fText = '' then txt := Name else txt := fText;
    if (txt<> '') then
    begin
      sFontname := IdeStyle.font_family;
      if sFontname = '' then sFontname := 'Times New Roman';
      Canvas.Font.Color:= clBlack;
      Canvas.Font.Name := sFontname;
      Canvas.Font.Style:= IdeStyle.font_style;
      if (Canvas.Font.Size <> IdeStyle.font_size) then SetBounds(Left,Top,Width,Height);
      Canvas.TextOut(2,2,txt);//
    end;
  end;
end;

procedure TYInput.SetBounds(aLeft, aTop, aWidth, aHeight: integer);
var
  sFontname : string;
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
      if (fUseControlHeight = false) then aHeight := Canvas.TextHeight (fText)+4;
      if (fUseControlWidth = false) then aWidth := 150;//Canvas.TextWidth(fText);
    end;
    if aHeight = 0 then aHeight:= 10;
    if aWidth = 0 then aWidth:= 3;
  end;
  inherited SetBounds(aLeft, aTop, aWidth, aHeight);
end;

function TYInput.YHTML: string;
var sEditingdone,sonchange : string;
  stype : string;
  sValues : string;
begin
  if Assigned(fOnEditingDone) then sEditingdone := 'onchange="ychange_' + Name+'(this.value)" '
  else sEditingdone:= '';
  if Assigned(fOnChange) then sonchange := 'oninput="yinput_' + Name+'(this.value)" '
  else sonchange:= '';
  case fInputType of
     TYitPassword : stype:= 'password';
     TYitText: stype:= 'text';
     TYitNumber: stype:= 'number';
  end;
  sValues := '';
  if fValueMin <> '' then sValues:= ' min = "'+fValueMin+'"';
  if fValueMax <> '' then sValues:= sValues+' max = "'+fValueMax+'"';
  if fValueStep <> '' then sValues:= sValues+' step = "'+fValueStep+'"';

//  if fTypePassword = true then stype:= 'password' else stype:= 'text';
  result := '<input type="'+stype+'"'+sValues +' name="' +Name + '" id="id' +Name
            + '" value="'+StrReplace(fText,'"','&quot;')+'" '+sonchange+sEditingdone
            + EncodeHtmlClassStyle + ' tabindex = "'+IntToStr(TabOrder)
            + '"'+BoolToStr(fReadOnly,' readonly','')+'>';
end;

function TYInput.Yscript: string;
var
  myCtrl : TWinControl;
  sTmp : string;
begin
    if Assigned(fTargetGrid) then UseFocusKeys:= false else UseFocusKeys:= true;
    result := '';

    if Assigned(fOnChange) then
    begin
      result := result +'function yinput_' + Name+'(val) {';
      sTmp := 'RefreshMe("input_'+name+':"+val);';
      myCtrl :=  fTargetView;
      if not Assigned(myCtrl) then myCtrl := fTargetGrid;
      if  Assigned(myCtrl) then
      begin
        if myCtrl is TYCustomView  then
        sTmp :=  TYCustomView(myCtrl).JVS_getElementById+'.contentWindow.'+sTmp;

{        while not (myCtrl is TForm) do
        begin
           if myCtrl is TYCustomView  then
           begin
              sTmp:= 'document.getElementById("id'+myCtrl.Name+'").contentWindow.'+sTmp;
               sTmp:= 'document.getElementById("id'+myCtrl.Name+'").contentWindow.'+sTmp;
           end;
           myCtrl := myCtrl.Parent;
        end;   }
      end;
      result := result +JVS_ParentForm+sTmp;
      result := result +'}';
    end;
    if Assigned(fOnEditingDone) then
    begin
      result := result +'function ychange_' + Name+'(val) {';
      sTmp := 'RefreshMe("change_'+name+':"+val);';
      myCtrl :=  fTargetView;
      if not Assigned(myCtrl) then myCtrl := fTargetGrid;
      if Assigned(myCtrl) then
      begin
        if myCtrl is TYCustomView  then
        sTmp :=  TYCustomView(myCtrl).JVS_getElementById+'.contentWindow.'+sTmp;
      end;
      result := result +JVS_ParentForm+sTmp;
      result := result +'}';
    end;
end;

procedure TYInput.FillFromRequest(ARequestContent: TStrings;
  var vOnClick: TYHtmlEvent;var Sender:TObject; YHTMLEXIT: string;var ErrorMessage : string);
var stmp : string;
begin
    inherited FillFromRequest(ARequestContent, vOnClick,Sender, YHTMLEXIT,ErrorMessage);
    if Self.Generate = false then exit;
    if Self.fReadOnly = true then exit;
    if Assigned(fOnChange) or Assigned(fOnEditingDone) then
    begin
        stmp := StrToken(YHTMLEXIT,':');
        if stmp = ('input_'+name) then
        begin
           Text := YHTMLEXIT;
           vOnClick := TYHtmlEvent(fOnChange);
           Sender := self;
        end;
        if stmp = ('change_'+name) then
        begin
           Text := YHTMLEXIT;
           vOnClick := TYHtmlEvent(fOnEditingDone);
           Sender := self;
        end;
    end;
end;

function TYInput.Yscript_keydown: string;
begin
  if Assigned(fTargetGrid) then result := 'if ((key ==35)||(key==36)) {key=0;}'+ fTargetGrid.Yscript_keydown else result := '';
end;

end.
