unit YCheckBox;

{$mode objfpc}{$H+}

interface

uses YHtmlControl,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;

type

  { TYCheckBox }

  TYCheckBox = class(TYHtmlControl)
  private

  protected
    fOnChange : TYHtmlEvent;
    fTargetView : TYCustomView;
    fChecked : boolean;
    fReadOnly : Boolean;
    procedure SetfText(AValue: string);override;
    procedure UseControlDesign;override;
    procedure Loaded;override;

  public
    constructor Create(TheOwner: TComponent);override;
    procedure Paint; override;
    procedure SetBounds(aLeft, aTop, aWidth, aHeight: integer); override;
    procedure PutUseControlWidth(aValue : boolean); override;
    function YHTML: string;override;
    procedure FillFromRequest(ARequestContent : TStrings; var vOnClick : TYHtmlEvent;var Sender:TObject;YHTMLEXIT : string;var ErrorMessage : string);override;
    function Yscript : string; override;
    function Yscript_keydown: string; override;
    function YInnerName : string;override;
  published
    property OnChange : TYHtmlEvent read fOnChange write fOnChange;
    property TargetView : TYCustomView read fTargetView write fTargetView;
    property Checked : boolean read fChecked write fChecked;
    property ReadOnly : boolean read fReadOnly write fReadOnly;
    property TabOrder;
    property TabStop;
  end;

procedure Register;

implementation

uses YClass,strprocs;

procedure Register;
begin
  {$I ycheckbox_icon.lrs}
  RegisterComponents('YHTML',[TYCheckBox]);
end;

{ TYCheckBox }


constructor TYCheckBox.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  FocusEnabled := true;
  UseFocusKeys := true;
end;

procedure TYCheckBox.SetfText(AValue: string);
begin
  fText:= AValue;
  if (csDesigning in ComponentState) and  (not (csLoading in ComponentState)) then
  begin
    SetBounds(Left,Top,Width,Height);
  end;
end;

procedure TYCheckBox.UseControlDesign;
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

procedure TYCheckBox.Loaded;
begin
  inherited Loaded;
end;

procedure TYCheckBox.Paint;
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
    Canvas.Rectangle(0,4,8,12);
    if Checked = true then
    begin
      Canvas.Line(0,4,8,12);Canvas.Line(8,4,0,12);
    end;
    Canvas.TextOut(10,0,fText);
  end;
end;

procedure TYCheckBox.SetBounds(aLeft, aTop, aWidth, aHeight: integer);
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
      if (fUseControlWidth = false) then aWidth := Canvas.TextWidth(fText)+10;
    end;
    if aHeight = 0 then aHeight:= 10;
    if aWidth = 0 then aWidth:= 10;
  end;
  inherited SetBounds(aLeft, aTop, aWidth, aHeight);
end;

procedure TYCheckBox.PutUseControlWidth(aValue: boolean);
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

function TYCheckBox.YHTML: string;
var sonchange,schecked : string;

begin
  if fChecked = true then schecked:= ' checked' else schecked := '';
  if Assigned(fOnChange) then sonchange := 'onchange="ycheckBox_' + Name+'(this.checked)" '
  else sonchange:= '';
  result := '<span id="id' +Name +'"'+EncodeHtmlClassStyle +'><input type="hidden" name="yExist' +Name
  + '"><input'+BoolToStr(ReadOnly,' disabled="disabled"','')+' id ="idinner'+Name+'" type="checkbox" name="' +Name + '" '+sonchange +  ' tabindex = "'+IntToStr(TabOrder) +'"'+schecked+'>'+fText+'</span>';
end;

procedure TYCheckBox.FillFromRequest(ARequestContent: TStrings;
  var vOnClick: TYHtmlEvent; var Sender: TObject; YHTMLEXIT: string;var ErrorMessage : string);
var stmp : string;
begin
  if Self.ReadOnly = true then exit;
  if Self.Generate = false then exit;

   if ARequestContent.IndexOfName(Name) >= 0 then Checked := True else
   if ARequestContent.IndexOfName('yExist'+Name) >= 0 then Checked := false;

   if Assigned(fOnChange) then
   begin
        stmp := StrToken(YHTMLEXIT,':');
        if stmp = ('checkbox_'+name) then
        begin
           Checked:= StrToBool(YHTMLEXIT);
           vOnClick := TYHtmlEvent(fOnChange);
           Sender := self;
        end;
   end;
end;

function TYCheckBox.Yscript: string;
var
  myCtrl : TWinControl;
  sTmp : string;
begin
    result := 'document.getElementById("id'+Name+
    '").addEventListener("click",function(){document.getElementById("id'+YInnerName+'").focus();});';
    if Assigned(fOnChange) then
    begin
      result := result +'function ycheckBox_' + Name+'(val) {';
      sTmp := 'RefreshMe("checkbox_'+name+':"+val);';
      myCtrl :=  fTargetView;
//      if not Assigned(myCtrl) then myCtrl := fTargetGrid;
      if  Assigned(myCtrl) then
      begin
        while not (myCtrl is TForm) do
        begin
           if myCtrl is TYCustomView  then
           begin
              sTmp:= 'document.getElementById("id'+myCtrl.Name+'").contentWindow.'+sTmp;
           end;
           myCtrl := myCtrl.Parent;
        end;
      end;
      result := result +JVS_ParentForm+sTmp;
      result := result +'}';
    end;
end;

function TYCheckBox.Yscript_keydown: string;
begin
  Result:='if (key == 37) {key=38;};if (key == 39) {key=40;};';
end;

function TYCheckBox.YInnerName: string;
begin
  Result:= 'inner'+Self.Name;
end;

end.
