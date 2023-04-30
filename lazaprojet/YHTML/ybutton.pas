unit YButton;

{$mode objfpc}{$H+}

interface

uses
  YHtmlControl,YHtmlComponent,yView,extctrls,LCLType,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;

type

  { TYButton }

  TYButton = class(TYHtmlControl)
  private
    MyImage : TImage;
    fIDEPreviewFile : string;
    procedure SetIDEPreviewFile(AValue: string);
    procedure SetShortcutKeyCode(AValue: word);
    procedure SetShortcutKeyLabel(AValue: string);
  protected
    fOnClick : TYHtmlEvent;
    fConfirmation : string;
    fTargetView : TYCustomView;
    fShortcutKeyCode : word;
    fShortcutKeyLabel : string;
  public
    constructor Create(TheOwner: TComponent);override;
    procedure Paint; override;
    procedure SetBounds(aLeft, aTop, aWidth, aHeight: integer); override;
//    procedure DoClick;
    function YHTML: string;override;
    function GetAutoPictureFile : string;
    procedure PutAutoPictureFile(aValue : string);
    procedure UseControlDesign;override;
    procedure FillFromRequest(ARequestContent : TStrings; var vOnClick : TYHtmlEvent;var Sender:TObject ;YHTMLEXIT : string;var ErrorMessage : string);override;
    function Yscript : string; override;
    function Yscript_keydown: string; override;
  published
    property OnClick: TYHtmlEvent read fOnClick write fOnClick;
    property AutoPictureFile : string read GetAutoPictureFile write PutAutoPictureFile;
    property Confirmation : string read fConfirmation write fConfirmation;
    property TargetView : TYCustomView read fTargetView write fTargetView;
    property IDEPreviewFile : string read fIDEPreviewFile write SetIDEPreviewFile;
    property ShortcutKeyCode : word read fShortcutKeyCode write SetShortcutKeyCode;
    property ShortcutKeyLabel : string read fShortcutKeyLabel write SetShortcutKeyLabel;
    property TabOrder;
    property TabStop;
  end;

procedure Register;

implementation

uses strprocs,PropEdits,YClass;

procedure Register;
begin
  {$I ybutton_icon.lrs}
  RegisterComponents('YHTML',[TYButton]);
end;

{ TYButton }

constructor TYButton.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  fHtmlStyle.Margin := '2px';
  FocusEnabled:= true;
  UseFocusKeys:=true;
  Height:= 16;
  Width := 64;
  fConfirmation := '';
  ShortcutKeyCode := 0;
  if (csDesigning in ComponentState) then
  begin
    MyImage:= TImage.Create(self);
    MyImage.Parent := self;
    MyImage.AutoSize := true;
    MyImage.Stretch:= true;
    MyImage.Align:= alTop;
  end;
end;

procedure TYButton.SetIDEPreviewFile(AValue: string);
begin
    fIDEPreviewFile := AValue;
    if fIDEPreviewFile<> '' then
    begin
      if (csDesigning in ComponentState) then
      if FileExists(fIDEPreviewFile) then
        MyImage.Picture.LoadFromFile(fIDEPreviewFile);
    end
    else MyImage.Picture.Clear;
end;

procedure TYButton.SetShortcutKeyCode(AValue: word);
begin
  if fShortcutKeyCode=AValue then Exit;
  if AValue = 27 then fShortcutKeyLabel:= 'ECH';
  if AValue = 32 then fShortcutKeyLabel:= 'Espace';
  if AValue = 112 then fShortcutKeyLabel:= 'F1';
  if AValue = 113 then fShortcutKeyLabel:= 'F2';
  if AValue = 114 then fShortcutKeyLabel:= 'F3';
  if AValue = 115 then fShortcutKeyLabel:= 'F4';
  if AValue = 116 then fShortcutKeyLabel:= 'F5';
  if AValue = 117 then fShortcutKeyLabel:= 'F6';
  if AValue = 118 then fShortcutKeyLabel:= 'F7';
  if AValue = 119 then fShortcutKeyLabel:= 'F8';
  if AValue = 120 then fShortcutKeyLabel:= 'F9';
  if AValue = 121 then fShortcutKeyLabel:= 'F10';
  if AValue = 122 then fShortcutKeyLabel:= 'F11';
  if AValue = 123 then fShortcutKeyLabel:= 'F12';
  if AValue = 13 then fShortcutKeyLabel:= 'ENT';

  if AValue = 96 then fShortcutKeyLabel:= '0';
  if AValue = 97 then fShortcutKeyLabel:= '1';
  if AValue = 98 then fShortcutKeyLabel:= '2';
  if AValue = 99 then fShortcutKeyLabel:= '3';
  if AValue = 100 then fShortcutKeyLabel:= '4';
  if AValue = 101 then fShortcutKeyLabel:= '5';
  if AValue = 102 then fShortcutKeyLabel:= '6';
  if AValue = 103 then fShortcutKeyLabel:= '7';
  if AValue = 104 then fShortcutKeyLabel:= '8';
  if AValue = 105 then fShortcutKeyLabel:= '9';
  if AValue = 107 then fShortcutKeyLabel:= '+';
  if AValue = 109 then fShortcutKeyLabel:= '-';
  if AValue = 110 then fShortcutKeyLabel:= '.';

  if AValue = 37 then fShortcutKeyLabel:= 'Gauche';
  if AValue = 38 then fShortcutKeyLabel:= 'Haut';
  if AValue = 39 then fShortcutKeyLabel:= 'Droite';
  if AValue = 40 then fShortcutKeyLabel:= 'Bas';

  fShortcutKeyCode:=AValue;
end;

procedure TYButton.SetShortcutKeyLabel(AValue: string);
begin
  if fShortcutKeyLabel=AValue then Exit;
  if AValue = 'ECH'  then fShortcutKeyCode:= 27;
  if AValue = 'Espace' then fShortcutKeyCode:= 32;
  if AValue = 'F1' then fShortcutKeyCode:= 112;
  if AValue = 'F2' then fShortcutKeyCode:= 113;
  if AValue = 'F3' then fShortcutKeyCode:= 114;
  if AValue = 'F4' then fShortcutKeyCode:= 115;
  if AValue = 'F5' then fShortcutKeyCode:= 116;
  if AValue = 'F6' then fShortcutKeyCode:= 117;
  if AValue = 'F7' then fShortcutKeyCode:= 118;
  if AValue = 'F8' then fShortcutKeyCode:= 119;
  if AValue = 'F9' then fShortcutKeyCode:= 120;
  if AValue = 'F10' then fShortcutKeyCode:= 121;
  if AValue = 'F11' then fShortcutKeyCode:= 122;
  if AValue = 'F12' then fShortcutKeyCode:= 123;
  if AValue = 'ENT' then fShortcutKeyCode:= 13;
  if AValue = '0' then fShortcutKeyCode:= 96;
  if AValue = '1' then fShortcutKeyCode:= 97;
  if AValue = '2' then fShortcutKeyCode:= 98;
  if AValue = '3' then fShortcutKeyCode:= 99;
  if AValue = '4' then fShortcutKeyCode:= 100;
  if AValue = '5' then fShortcutKeyCode:= 101;
  if AValue = '6' then fShortcutKeyCode:= 102;
  if AValue = '7' then fShortcutKeyCode:= 103;
  if AValue = '8' then fShortcutKeyCode:= 104;
  if AValue = '9' then fShortcutKeyCode:= 105;
  if AValue = '+' then fShortcutKeyCode:= 107;
  if AValue = '-' then fShortcutKeyCode:= 109;
  if AValue = '.' then fShortcutKeyCode:= 110;

  if AValue = 'Gauche' then fShortcutKeyCode:= 37;
  if AValue = 'Haut' then fShortcutKeyCode:= 38;
  if AValue = 'Droite' then fShortcutKeyCode:= 39;
  if AValue = 'Bas' then fShortcutKeyCode:= 40;

  fShortcutKeyLabel:=AValue;
end;

procedure TYButton.Paint;
var poxy: integer;
begin
  inherited Paint;
  Canvas.Brush.Color:=$F0F0F0;
  Canvas.FillRect(0,0,Width-1,Height-1);
  Canvas.pen.Color:=clDkGray;
  Canvas.Rectangle(0,0,Width-1,Height-1);
  Canvas.Font.Color:=clBlack;
  poxy := 2;
  if IDEPreviewFile = '' then
  begin
    Canvas.TextOut(2,30,AutoPictureFile);
  end
  else
  begin
    if fText <> '' then
    begin;
      poxy := Height- Canvas.TextHeight (fText)-2;;
    end;
  end;
  Canvas.TextOut(2,poxy,fText);
end;

procedure TYButton.SetBounds(aLeft, aTop, aWidth, aHeight: integer);
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
      if (fUseControlHeight = false) then aHeight := Canvas.TextHeight (fText)+4;
      if (fUseControlWidth = false) then aWidth := Canvas.TextWidth(fText)+6;
    end;
    if aHeight = 0 then aHeight:= 10;
    if aWidth = 0 then aHeight:= 3;
    if Assigned(MyImage) then if IDEPreviewFile = '' then MyImage.Height:= 0 else MyImage.Height := ((5*aHeight) div 4);

  end;
//  aWidth := Canvas.TextWidth(fText)+4;
//  if aHeight<8 then aHeight:= 8;
//  if aWidth <8 then aHeight:= 8;


  inherited SetBounds(aLeft, aTop, aWidth, aHeight);
end;

{procedure TYButton.DoClick;
begin
  if Assigned(fOnClick) then fOnClick;
end;   }

function TYButton.YHTML : string;
var sshortkey : string;
begin
  sshortkey := '';
  if fShortcutKeyLabel <> '' then sshortkey := ' title="' +fShortcutKeyLabel + '"';
  if (fConfirmation = '') and (not  Assigned(fTargetView)) then
     result := '<input type="submit" name="' +Name + '"  id="id' +Name + '" '+ EncodeHtmlClassStyle+sshortkey+' value="'+Text+'">'
  else
    result := '<input type="button" name="' +Name + '"  id="id' +Name + '" '+ EncodeHtmlClassStyle+sshortkey+' value="'+Text+'" onclick = "button_' + Name+'_click()">';
end;

function TYButton.GetAutoPictureFile: string;
begin
   result := HtmlStyle.background_image;
   StrToken(result,'/'+CYURIFile+'/');
end;

procedure TYButton.PutAutoPictureFile(aValue: string);
begin
  if aValue <> GetAutoPictureFile then
  begin
    if aValue = '' then
    begin
      if HtmlStyle.background_size=  '80% 80%' then HtmlStyle.background_size :=  '';
      HtmlStyle.background_image:= '';
      if HtmlStyle.background_position=  'center top' then HtmlStyle.background_position :=  '';
      if HtmlStyle.background_repeat=  'no-repeat' then HtmlStyle.background_repeat :=  '';
      if (fUseControlHeight = true) and (HtmlStyle.padding_top = IntToStr((Height * 80) div 100) + 'px') then HtmlStyle.padding_top := '';
    end
    else
    begin
      HtmlStyle.background_image:= '/'+CYURIFile+'/'+aValue;
      HtmlStyle.background_size:=  '80% 80%';
      HtmlStyle.background_position:= 'center top';
      HtmlStyle.background_repeat:=  'no-repeat';
      if fUseControlHeight = true then  HtmlStyle.padding_top := IntToStr((Height * 80) div 100) + 'px';
    end;
  end;
end;

procedure TYButton.UseControlDesign;
begin
    inherited;
    if fUseControlHeight = true then
    begin
      if (AutoPictureFile <> '') and (HtmlStyle.padding_top =  '') then
      begin
         HtmlStyle.padding_top := IntToStr((Height * 80) div 100) + 'px';
      end;
    end;
end;

procedure TYButton.FillFromRequest(ARequestContent: TStrings;
  var vOnClick: TYHtmlEvent;var Sender:TObject ; YHTMLEXIT: string;var ErrorMessage : string);
begin
  inherited FillFromRequest(ARequestContent, vOnClick,Sender, YHTMLEXIT,ErrorMessage);
  if Self.Generate = false then exit;
  if (YHTMLEXIT = 'button_'+name) then if Assigned(fOnClick) then
  begin
    vOnClick := TYHtmlEvent(fOnClick);
    Sender := self;
  end;
  if ARequestContent.IndexOfName(Name) >=0 then
    if Assigned(fOnClick) then
    begin
      vOnClick := TYHtmlEvent(fOnClick);
      Sender := self;
    end;
end;

function TYButton.Yscript: string;
var
  sTmp : string;
begin
    result := '';
    if (fConfirmation <> '') or Assigned(fTargetView) then
    begin
      result := result +'function button_' + Name+'_click() {';
      if (fConfirmation <> '') then
      begin
        result := result +'var r = confirm("'+fConfirmation+'");';
        result := result +'if (r == true) {';
      end;
      sTmp := 'RefreshMe("button_'+name+'");';
      if  Assigned(fTargetView) then sTmp:= fTargetView.JVS_getElementById+'.contentWindow.'+sTmp;
      result := result +JVS_ParentForm+sTmp;
      if (fConfirmation <> '') then result := result +'}';
      result := result +'}';
    end;
end;

function TYButton.Yscript_keydown: string;
begin
  if TabStop = true then
    Result:='if (key == 37) {key=38;};if (key == 39) {key=40;};if (key == 13) {key=32;};'
  else result := '';
end;

begin

RegisterPropertyEditor(TypeInfo(Integer),TYButton,'Height',TIntegerPropertyEditor );
RegisterPropertyEditor(TypeInfo(Integer),TYButton,'Width',TIntegerPropertyEditor);
end.
