unit YCombo;

{$mode objfpc}{$H+}

interface

uses
  YHtmlControl,yView,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;

type

  { TYCombo }

  TYCombo = class(TYHtmlControl)
  private
    felements :Tstrings;
    procedure Setfelement(AValue: tStrings);

  protected
    fReadOnly : Boolean;
    fOnChange : TYHtmlEvent;
    fTargetView : TYView;
  public
    destructor Destroy; override;
    procedure Paint; override;
    procedure SetBounds(aLeft, aTop, aWidth, aHeight: integer); override;
    function YHTML: string;override;
    function Yscript : string; override;
    procedure FillFromRequest(ARequestContent : TStrings; var vOnClick : TYHtmlEvent;var Sender:TObject;YHTMLEXIT : string;var ErrorMessage : string);override;
    function Yscript_keydown: string; override;
  published
    constructor Create(TheOwner: TComponent);override;
    property Elements : tStrings read felements write Setfelement;
    property OnChange : TYHtmlEvent read fOnChange write fOnChange;
    property ReadOnly : boolean read fReadOnly write fReadOnly;
    property TargetView : TYView read fTargetView write fTargetView;
    property TabOrder;
    property TabStop;
  end;

procedure Register;

implementation

uses strprocs;

procedure Register;
begin
  {$I ycombo_icon.lrs}
  RegisterComponents('YHTML',[TYCombo]);
end;

{ TYCombo }

constructor TYCombo.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  felements := tstringlist.Create;
  FocusEnabled := true;
  UseFocusKeys := true;
  if (csDesigning in ComponentState)  then
  begin
      Height:= 23;
      fHtmlStyle.Margin := '2px';
  end;
end;

procedure TYCombo.Setfelement(AValue: tStrings);
begin
  felements.Text :=AValue.Text;
end;

procedure TYCombo.Paint;
var
  sFontname : string;
begin
  inherited Paint;
  if  (csDesigning in ComponentState)  then
  begin
    Canvas.Pen.Color:= clBlack;
    Canvas.Brush.Color:= clWhite;
    Canvas.Rectangle(0,0,Width,Height);
    if (fText<> '') then
    begin
      sFontname := IdeStyle.font_family;
      if sFontname = '' then sFontname := 'Times New Roman';
      Canvas.Font.Color:= clBlack;
      Canvas.Font.Name := sFontname;
      Canvas.Font.Style:= IdeStyle.font_style;
      if (Canvas.Font.Size <> IdeStyle.font_size) then SetBounds(Left,Top,Width,Height);
      Canvas.TextOut(2,2,ftext);//
    end;
    Canvas.Line(Width-3,3,Width-6,6);
    Canvas.Line(Width-6,6,Width-10,2);
    Canvas.Line(Width-3,4,Width-6,7);
    Canvas.Line(Width-6,7,Width-10,3);
  end;
end;

procedure TYCombo.SetBounds(aLeft, aTop, aWidth, aHeight: integer);
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

function TYCombo.YHTML: string;
var sonchange : string;
  i : integer;
  sElt : string;
begin
  if Assigned(fOnChange) then   sonchange := 'onchange="ycombo_' + Name+'(this.value)" '
  else sonchange:= '';
  result := '<select name="' +Name + '" id="id' +Name +'" '+sonchange + EncodeHtmlClassStyle + '>';
  for i := 0 to Elements.Count-1 do
  begin
    sElt :=  Elements[i];
    if (ReadOnly = false) or  (fText = sElt) then
    begin
      Result := Result + '<option value="'+sElt+  '"';
      if fText = sElt then Result := Result + ' selected';
      Result := Result +'>'+sElt+'</option>;';
    end;
  end;
  Result := Result +'</select>';

end;

function TYCombo.Yscript: string;
var
  myCtrl : TWinControl;
  sTmp : string;
begin
    result := '';
    if Assigned(fOnChange) then
    begin
      result := result +'function ycombo_' + Name+'(val) {';
      sTmp := 'RefreshMe("combo_'+name+':"+val);';
      if  Assigned(fTargetView) then
      begin
        myCtrl :=  fTargetView;
        while not (myCtrl is TForm) do
        begin
           if myCtrl is TYView then
           begin
              sTmp:= 'document.getElementById("id'+myCtrl.Name+'").contentWindow.'+sTmp;
           end;
           myCtrl := myCtrl.Parent;
        end;
        sTmp :='parent.'+sTmp;
      end;
      result := result +sTmp;
      result := result +'}';
    end;
end;

procedure TYCombo.FillFromRequest(ARequestContent: TStrings;
  var vOnClick: TYHtmlEvent; var Sender: TObject; YHTMLEXIT: string;var ErrorMessage : string);
var stmp : string;
begin
    inherited FillFromRequest(ARequestContent, vOnClick,Sender, YHTMLEXIT,ErrorMessage);
    if Self.Generate = false then exit;
    if Self.ReadOnly = true then exit;

    if Assigned(fOnChange) then
    begin
        stmp := StrToken(YHTMLEXIT,':');
        if stmp = ('combo_'+name) then
        begin
           Text := YHTMLEXIT;
           vOnClick := TYHtmlEvent(fOnChange);
           Sender := self;
        end;
    end;
end;

function TYCombo.Yscript_keydown: string;
begin
  Result:='if (key == 38) {key=0;};if (key == 40) {key=0;};if (key == 37) {key=38;};if (key == 39) {key=40;};';
end;

destructor TYCombo.Destroy;
begin
  try
    felements.free;
  except
  end;
  inherited Destroy;
end;

end.
