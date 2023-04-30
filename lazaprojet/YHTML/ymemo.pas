unit YMemo;

{$mode objfpc}{$H+}

interface

uses
  YHtmlControl,yView,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;

type

  { TYMemo }

  TYMemo = class(TYHtmlControl)
  private
    fcontentlines :Tstrings;
    fOnChange: TYHtmlEvent;
    fTargetView : TYView;
    procedure Setfcontentlines(AValue: tStrings);
  protected
    fReadOnly : Boolean;
  public
    destructor Destroy; override;
    function YHTML: string;override;
    function Yscript : string; override;
    procedure FillFromRequest(ARequestContent : TStrings; var vOnClick : TYHtmlEvent;var Sender:TObject;YHTMLEXIT : string;var ErrorMessage : string);override;
    constructor Create(TheOwner: TComponent);override;
    procedure Paint; override;
    procedure SetBounds(aLeft, aTop, aWidth, aHeight: integer); override;
    property Lines : tStrings read fcontentlines write Setfcontentlines;
  published
    property OnChange : TYHtmlEvent read fOnChange write fOnChange;
    property TargetView : TYView read fTargetView write fTargetView;
    property ReadOnly : boolean read fReadOnly write fReadOnly;
    property TabOrder;
    property TabStop;
  end;

procedure Register;

implementation

uses strprocs;
procedure Register;
begin
  {$I ymemo_icon.lrs}
  RegisterComponents('YHTML',[TYMemo]);
end;

{ TYMemo }

constructor TYMemo.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  fcontentlines := tstringlist.Create;
  FocusEnabled := true;  UseFocusKeys := false;
  if (csDesigning in ComponentState)  then
  begin
     fHtmlStyle.Margin := '2px';
  end;
end;

destructor TYMemo.Destroy;
begin
  try
    fcontentlines.free;
  except
  end;
  inherited Destroy;
end;

procedure TYMemo.Setfcontentlines(AValue: tStrings);
begin
  fcontentlines.Text :=AValue.Text;
end;

procedure TYMemo.Paint;
var fs,i : integer;lg : string;
  sFontname : string;
begin
  inherited Paint;
  if  (csDesigning in ComponentState)  then
  begin
    Canvas.Pen.Color:= clBlack;
    Canvas.Brush.Color:= clWhite;
    Canvas.Rectangle(0,0,Width,Height);
    if (fcontentlines.Text<> '') then
    begin
      sFontname := IdeStyle.font_family;
      if sFontname = '' then sFontname := 'Times New Roman';
      Canvas.Font.Color:= clBlack;
      Canvas.Font.Name := sFontname;
      Canvas.Font.Style:= IdeStyle.font_style;
      try
        fs := Canvas.TextHeight('*');
      except
        fs := 14;
      end;
      for i := 0 to fcontentlines.Count-1 do
      begin
        lg := fcontentlines.Strings[i];
        Canvas.TextOut(2,2+(i*fs),lg);
      end;
    end;
  end;
end;

procedure TYMemo.SetBounds(aLeft, aTop, aWidth, aHeight: integer);
begin
  if aWidth<8 then aWidth:= 8;
  if aHeight<8 then aHeight:= 8;
  inherited SetBounds(aLeft, aTop, aWidth, aHeight);
end;

function TYMemo.YHTML: string;
var sonchange : string;
begin
  if Assigned(fOnChange) then   sonchange := 'oninput="yinput_' + Name+'(this.value)" '
  else sonchange:= '';
  result := '<textarea'+BoolToStr(ReadOnly,' readonly','')+' name="' +Name + '" id="id' +Name +'" ' + EncodeHtmlClassStyle+sonchange + '>'
     +StrReplace(fcontentlines.Text,'"','&quot;')+'</textarea>';
end;

function TYMemo.Yscript: string;
var
  myCtrl : TWinControl;
  sTmp : string;
begin
    result := '';
    if Assigned(fOnChange) then
    begin
      result := result +'function ymemo_' + Name+'(val) {';
      sTmp := 'RefreshMe("memo_'+name+':"+val);';
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

procedure TYMemo.FillFromRequest(ARequestContent: TStrings;
  var vOnClick: TYHtmlEvent; var Sender: TObject; YHTMLEXIT: string;var ErrorMessage : string);
var stmp : string;
begin
    if Self.Generate = false then exit;
    if Self.ReadOnly = true then exit;
    if ARequestContent.IndexOfName(Name) >=0 then Lines.Text := ARequestContent.Values[Name];
    if Assigned(fOnChange) then
    begin
        stmp := StrToken(YHTMLEXIT,':');
        if stmp = ('memo_'+name) then
        begin
           Text := YHTMLEXIT;
           vOnClick := TYHtmlEvent(fOnChange);
           Sender := self;
        end;
    end;
end;

end.
