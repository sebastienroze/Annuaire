unit YClass;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;

type

  TYText_align = (TYtLEFT,TYtRight,TYtCenter,TYtJustify);
  TYFloat = (TYfNONE,TYfLeft,TYfRight,TYfInitial,TYfInherit);
  TYPosition = (TYpSTATIC,TYpAbsolute,TYpFixed,TYpRelative,TYpSticky,TYpInitial,TYpInherit);
  TYDisplay  = (TYdNONE,TYdInline,TYdBlock,TYdInline_Block);
  TYText_transform  = (TYttNONE,TYttCapitalize,TYttUppercase,TYttLowerCase,TYttInitial,TYttInherit);

  { TYHtmlStyle }

  TYHtmlStyle = class(TPersistent)
  private
    fbackground_color : String;
    fcolor : String;
    ffont_family : String;
    ffont_size : integer;
    ftext_align  : TYText_align;
    ffont_style  : TFontStyles;
    fHidden : Boolean;
    fbackground_image : String;
    fbackground_size : String;
    fbackground_position : String;
    fbackground_repeat : String;
    fwidth : string;
    fheight : string;
    fcursor : string;
    ftop,fleft,fright,fbottom : string;
    fpadding_top,fpadding_left,fpadding_right,fpadding_bottom : string;
    fborder,fborder_top,fborder_left,fborder_right,fborder_bottom : string;
    fFloat : TYFloat;
    fPosition : TYPosition;
    fDisplay : TYDisplay;
    fcustom_style: string;
    fMargin: string;
    ftext_transform:TYText_transform;
  protected
  public
    procedure AssignTo(Dest: TPersistent);override;
    procedure Clear;
    function EncodeHtmlStyle : string;
    procedure AddHtmlStyle(aHtmlStyle : TYHtmlStyle);
  published
    property text_transform : TYText_transform read ftext_transform write ftext_transform ;
    property margin : String read fMargin write fMargin ;
    property cursor : String read fcursor write fcursor ;
    property custom_style : String read fcustom_style write fcustom_style ;

    property position_width : String read fwidth write fwidth ;
    property position_height : String read fheight write fheight ;
    property position_left: String read fleft write fleft;
    property position_top : String read ftop write ftop;
    property position_right: String read fright write fright ;
    property position_bottom: String read fbottom write fbottom;

    property padding_left: String read fpadding_left write fpadding_left;
    property padding_top : String read fpadding_top write fpadding_top;
    property padding_right: String read fpadding_right write fpadding_right ;
    property padding_bottom: String read fpadding_bottom write fpadding_bottom;

    property border: String read fborder write fborder;
    property border_left: String read fborder_left write fborder_left;
    property border_top : String read fborder_top write fborder_top;
    property border_right: String read fborder_right write fborder_right ;
    property border_bottom: String read fborder_bottom write fborder_bottom;

    property background_color : String read fbackground_color write fbackground_color ;
    property background_size : String read fbackground_size write fbackground_size ;
    property background_position : String read fbackground_position write fbackground_position ;
    property background_repeat : String read fbackground_repeat write fbackground_repeat ;
    property background_image : String read fbackground_image write fbackground_image;

    property font_color : String read fcolor write fcolor ;
    property font_family : String read ffont_family write ffont_family;
    property font_size : integer read ffont_size write ffont_size default 0;
    property font_style : TFontStyles read ffont_style write ffont_style;

    property text_align  : TYText_align read ftext_align write ftext_align;
    property float : TYFloat read fFloat write fFloat;
    property position : TYPosition read fPosition write fPosition;
    property display : TYDisplay read fDisplay write fDisplay;
    Property Hidden : Boolean  read fHidden write fHidden;
  end;

  TYClass = class(TComponent)
  private

    fHtmlStyle : TYHtmlStyle;
  public
    ElementAffected : string;
    constructor Create(TheOwner: TComponent);override;
    procedure AddCss(lines : Tstrings);
  published
    property HtmlStyle : TYHtmlStyle read fHtmlStyle write fHtmlStyle;
  end;


procedure Register;

function HtmlTextAlign(aTextAlign : TYText_align) : string;
function HtmlFloat(aFloat : TYFloat) : string;
function HtmlPosition(aPosition : TYPosition) : string;
function HtmlDisplay(aDisplay : TYDisplay) : string;
function HtmlTextTransform(aTextTransform : TYText_transform) : string;
function EncodeYHtmlClass(HtC : TYClass;ClassMulti: string) : string;

implementation

{ TYClass }

constructor TYClass.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  ElementAffected := '';
  fHtmlStyle := TYHtmlStyle.Create;
end;


procedure AddCssLineProperty(lines : Tstrings;PropertyName,value : string);
begin
    if value <> ''  then  lines.Add(PropertyName +':' +  value+';' );
end;

procedure TYClass.AddCss(lines : Tstrings);
var stmp : string;
begin
  lines.Add(ElementAffected +'.'+Name + ' {');
  if fHtmlStyle.font_size <> 0 then  lines.Add('font-size:' +  IntToStr(fHtmlStyle.font_size*84 div 10)+'%;');
  if fHtmlStyle.text_align <> TYtLEFT then  lines.Add('text-align:' +  HtmlTextAlign(fHtmlStyle.text_align)+';');
  if fHtmlStyle.float<> TYfNone then  lines.Add('float:' +  HtmlFloat(fHtmlStyle.float)+';');
  if fHtmlStyle.position<> TYpStatic then  lines.Add('position:' +  HtmlPosition(fHtmlStyle.position)+';');
  if fHtmlStyle.display<> TYdNONE then  lines.Add('display:' +  HtmlDisplay(fHtmlStyle.display )+';');
  if fHtmlStyle.text_transform<> TYttNONE then  lines.Add('text-transform:' +  HtmlTextTransform(fHtmlStyle.text_transform )+';');
  if (fsBold in fHtmlStyle.font_style) then lines.Add('font-weight: bold;');
  if (fsItalic in fHtmlStyle.font_style) then lines.Add('font-weight: italic;');
  if (fsUnderline in fHtmlStyle.font_style) or (fsStrikeOut in fHtmlStyle.font_style) then
  begin
    stmp := 'text-decoration:' ;
    if (fsUnderline in fHtmlStyle.font_style) then stmp := stmp + ' underline';
    if (fsStrikeOut in fHtmlStyle.font_style) then stmp := stmp + ' line-through';
    stmp := stmp +';';
    lines.Add(stmp);
  end;

  AddCssLineProperty(lines,'background-color',fHtmlStyle.background_color );
  AddCssLineProperty(lines,'color',fHtmlStyle.font_color);
  AddCssLineProperty(lines,'font-family',fHtmlStyle.font_family);

  AddCssLineProperty(lines,'width',fHtmlStyle.position_width );
  AddCssLineProperty(lines,'height',fHtmlStyle.position_height);
  AddCssLineProperty(lines,'top',fHtmlStyle.position_top);
  AddCssLineProperty(lines,'left',fHtmlStyle.position_left);
  AddCssLineProperty(lines,'right',fHtmlStyle.position_right);
  AddCssLineProperty(lines,'bottom',fHtmlStyle.position_bottom);

  AddCssLineProperty(lines,'padding-top',fHtmlStyle.padding_top);
  AddCssLineProperty(lines,'padding-left',fHtmlStyle.padding_left);
  AddCssLineProperty(lines,'padding-right',fHtmlStyle.padding_right);
  AddCssLineProperty(lines,'padding-bottom',fHtmlStyle.padding_bottom);

  AddCssLineProperty(lines,'border',fHtmlStyle.border);
  AddCssLineProperty(lines,'border-top',fHtmlStyle.border_top);
  AddCssLineProperty(lines,'border-left',fHtmlStyle.border_left);
  AddCssLineProperty(lines,'border-right',fHtmlStyle.border_right);
  AddCssLineProperty(lines,'border-bottom',fHtmlStyle.border_bottom);

  AddCssLineProperty(lines,'cursor',fHtmlStyle.cursor);
  AddCssLineProperty(lines,'margin',fHtmlStyle.margin);
  if fHtmlStyle.custom_style <> '' then lines.Add(fHtmlStyle.custom_style);
  if fHtmlStyle.Hidden = true then lines.Add('visibility: hidden;');
  lines.Add('}');
end;

{ TYHtmlStyle }

procedure TYHtmlStyle.AssignTo(Dest: TPersistent);
begin
  with Dest as TYHtmlStyle do
  begin
    fbackground_color :=self.fbackground_color;
    fcolor := self.fcolor ;
    ffont_family :=self.ffont_family ;
    ffont_size := self.ffont_size  ;
    ftext_align  := self.ftext_align ;
    ffont_style := self.ffont_style ;
    fHidden := self.fHidden;
    fbackground_image := self.fbackground_image;
    fbackground_size := self.fbackground_size;
    fbackground_position := self.fbackground_position;
    fbackground_repeat := self.fbackground_repeat;
    fwidth := self.fwidth;
    fheight := self.fheight;
    fcursor := self.fcursor;
    fmargin := self.fMargin;
    ftext_transform  := self.ftext_transform;
    ftop:= self.ftop;
    fpadding_top:= self.fpadding_top;
    fborder:= self.fborder;
    fFloat:= self.fFloat;
    fPosition:= self.fPosition;
    fDisplay:= self.fDisplay;
    fcustom_style:= self.fcustom_style;
    fleft:= self.fleft;
    fpadding_left:= self.fpadding_left;
    fborder_top:= self.fborder_top;
    fright:= self.fright;
    fpadding_right:= self.fpadding_right;
    fborder_left:= self.fborder_left;
    fbottom:= self.fbottom;
    fpadding_bottom:= self.fpadding_bottom;
    fborder_right:= self.fborder_right;
    fborder_bottom:= self.fborder_bottom;
  end;
end;

procedure TYHtmlStyle.AddHtmlStyle(aHtmlStyle: TYHtmlStyle);
begin
  if aHtmlStyle.fbackground_color <> '' then Self.fbackground_color := aHtmlStyle.fbackground_color;
  if aHtmlStyle.fcolor <> '' then Self.fcolor := aHtmlStyle.fcolor;
  if aHtmlStyle.ffont_family <> '' then Self.ffont_family := aHtmlStyle.ffont_family;
  if aHtmlStyle.ffont_size <> 0 then Self.ffont_size := aHtmlStyle.ffont_size;
  if aHtmlStyle.ftext_align <> TYtLEFT then Self.ftext_align := aHtmlStyle.ftext_align;
  if aHtmlStyle.ffont_style <>  []  then Self.ffont_style := aHtmlStyle.ffont_style;
  if aHtmlStyle.fHidden <> false then Self.fHidden := aHtmlStyle.fHidden;
  if aHtmlStyle.fbackground_image <> '' then Self.fbackground_image := aHtmlStyle.fbackground_image;
  if aHtmlStyle.fbackground_size <> '' then Self.fbackground_size := aHtmlStyle.fbackground_size;
  if aHtmlStyle.fbackground_position <> '' then Self.fbackground_position := aHtmlStyle.fbackground_position;
  if aHtmlStyle.fbackground_repeat <> '' then Self.fbackground_repeat := aHtmlStyle.fbackground_repeat;
  if aHtmlStyle.fwidth <> '' then Self.fwidth := aHtmlStyle.fwidth;
  if aHtmlStyle.fheight <> '' then Self.fheight := aHtmlStyle.fheight;
  if aHtmlStyle.fcursor <> '' then Self.fcursor := aHtmlStyle.fcursor;
  if aHtmlStyle.fmargin <> '' then Self.fmargin := aHtmlStyle.fmargin;
  if aHtmlStyle.ftext_transform <> TYttNONE then Self.ftext_transform := aHtmlStyle.ftext_transform;
  if aHtmlStyle.ftop <> '' then Self.ftop := aHtmlStyle.ftop;
  if aHtmlStyle.fpadding_top <> '' then Self.fpadding_top := aHtmlStyle.fpadding_top;
  if aHtmlStyle.fborder <> '' then Self.fborder := aHtmlStyle.fborder;
  if aHtmlStyle.fFloat <> TYfNONE then Self.fFloat := aHtmlStyle.fFloat;
  if aHtmlStyle.fPosition <> TYpSTATIC then Self.fPosition := aHtmlStyle.fPosition;
  if aHtmlStyle.fDisplay <> TYdNONE then Self.fDisplay := aHtmlStyle.fDisplay;
  if aHtmlStyle.fcustom_style <> '' then Self.fcustom_style := aHtmlStyle.fcustom_style;
  if aHtmlStyle.fleft <> '' then Self.fleft := aHtmlStyle.fleft;
  if aHtmlStyle.fpadding_left <> '' then Self.fpadding_left := aHtmlStyle.fpadding_left;
  if aHtmlStyle.fborder_top <> '' then Self.fborder_top := aHtmlStyle.fborder_top;
  if aHtmlStyle.fright <> '' then Self.fright := aHtmlStyle.fright;
  if aHtmlStyle.fpadding_right <> '' then Self.fpadding_right := aHtmlStyle.fpadding_right;
  if aHtmlStyle.fborder_left <> '' then Self.fborder_left := aHtmlStyle.fborder_left;
  if aHtmlStyle.fbottom <> '' then Self.fbottom := aHtmlStyle.fbottom;
  if aHtmlStyle.fpadding_bottom <> '' then Self.fpadding_bottom := aHtmlStyle.fpadding_bottom;
  if aHtmlStyle.fborder_right <> '' then Self.fborder_right := aHtmlStyle.fborder_right;
  if aHtmlStyle.fborder_bottom <> '' then Self.fborder_bottom := aHtmlStyle.fborder_bottom;
end;

procedure TYHtmlStyle.Clear;
begin
  fbackground_color :='';
  fcolor :='';
  ffont_family :='';
  ffont_size :=0 ;
  ftext_align  := TYtLEFT;
  ffont_style := [];
  fHidden :=false;
  fbackground_image :='';
  fbackground_size :='';
  fbackground_position :='';
  fbackground_repeat :='';
  fwidth :='';
  fheight :='';
  fcursor :='';
  fmargin := '';
  ftext_transform := TYttNONE;
  ftop:='';fleft:='';fright:='';fbottom :='';
  fpadding_top:='';fpadding_left:='';fpadding_right:='';fpadding_bottom :='';
  fborder:='';fborder_top:='';fborder_left:='';fborder_right:='';fborder_bottom :='';
  fFloat := TYfNONE;
  fPosition := TYpSTATIC;
  fDisplay := TYdNONE;
  fcustom_style:='';
end;

function EncodeProperty(PropertyName,value : string) : string;
begin
   if value <> '' then result := PropertyName+':'+value+';'  else result := '';
end;

function TYHtmlStyle.EncodeHtmlStyle : string;
begin
   result := 'style="';
   result := result + EncodeProperty('left',position_left );
   result := result + EncodeProperty('right',position_right);
   result := result + EncodeProperty('top',position_top);
   result := result + EncodeProperty('bottom',position_bottom);
   result := result + EncodeProperty('width',position_width);
   result := result + EncodeProperty('height',position_height);

   result := result + EncodeProperty('padding-bottom',fpadding_bottom);
   result := result + EncodeProperty('padding-top',fpadding_top);
   result := result + EncodeProperty('padding-left',fpadding_left);
   result := result + EncodeProperty('padding-right',fpadding_right);

   result := result + EncodeProperty('border',fborder);
   result := result + EncodeProperty('border-bottom',fborder_bottom);
   result := result + EncodeProperty('border-top',fborder_top);
   result := result + EncodeProperty('border-left',fborder_left);
   result := result + EncodeProperty('border-right',fborder_right);

   result := result + EncodeProperty('background-color',background_color);
   result := result + EncodeProperty('color',font_color);
   result := result + EncodeProperty('font-family',font_family);

   result := result + EncodeProperty('cursor',cursor);
   result := result + EncodeProperty('margin',margin);

   if font_size  <> 0 then result := result +'font-size:'+IntToStr(font_size*84 div 10)+'%;' ;
   if text_align <> TYtLEFT then result := result +'text-align:'+HtmlTextAlign(text_align)+';';
   if float<> TYfNone then  result := result +'float:' +  HtmlFloat(float)+';';
   if position<> TYpStatic then  result := result +'position:' +  HtmlPosition(position)+';';
   if display<> TYdNONE then  result := result +'display:' +  HtmlDisplay(display)+';';
   if text_transform<> TYttNONE then  result := result +'text-transform:' +  HtmlTextTransform(text_transform)+';';

   if (fsBold in font_style) then result := result +'font-weight: bold;' ;
   if (fsItalic in font_style) then result := result +'font-style: italic;' ;
   if (fsUnderline in font_style) or (fsStrikeOut in font_style) then
   begin
     result := result +'text-decoration:' ;
     if (fsUnderline in font_style) then result := result + ' underline';
     if (fsStrikeOut in font_style) then result := result + ' line-through';
     result := result +';';
   end;
   if Hidden  = true then result := result + 'visibility: hidden;';
   if background_image <> '' then
   result := result +'background-image:url('+background_image+');';
   //background-size:80% 80%;-o-background-size: 80% 80%;-webkit-background-size:80% 80%;background-position:center top;background-repeat:no-repeat;padding-top: 80px;';
   //background-size:contain;';

   result := result + EncodeProperty('background-size',background_size);
   result := result + EncodeProperty('-o-background-size',background_size);
   result := result + EncodeProperty('-webkit-background-size',background_size);
   result := result + EncodeProperty('background-repeat',background_repeat);
   result := result + EncodeProperty('background-position',background_position);

   result := result + custom_style;
   if result = 'style="' then Result := '' else result := result+'"';
end;

{ HTML functions }

function EncodeYHtmlClass(HtC : TYClass;ClassMulti: string) : string;
var sclass : string;
begin
  sclass := '';
  if Assigned( HtC) then sclass := HtC.name;
  if (sclass <> '') and  (ClassMulti <> '') then sclass := sclass + ' ';
  if (sclass + ClassMulti = '') then result := '' else
    result := 'class="'+sclass+ClassMulti+'" ';
end;

function HtmlTextAlign(aTextAlign : TYText_align) : string;
begin
  Result :='';
  case aTextAlign of
    TYtLeft : Result := 'Left';
    TYtCenter : Result := 'Center';
    TYtRight : Result := 'Right';
    TYtJustify : Result := 'Justify';
  end;
end;

function HtmlFloat(aFloat : TYFloat) : string;
begin
  Result :='';
  case aFloat of
    TYfNone : Result := 'none';
    TYfLeft : Result := 'left';
    TYfRight : Result := 'right';
    TYfInitial : Result := 'initial';
    TYfInherit : Result := 'inherit';
  end;
end;

function HtmlPosition(aPosition : TYPosition) : string;
begin
  Result :='';
  case aPosition of
    TYpStatic : Result := 'static';
    TYpAbsolute : Result := 'absolute';
    TYpFixed : Result := 'fixed';
    TYpRelative : Result := 'relative';
    TYpSticky : Result := 'sticky';
    TYpInitial : Result := 'initial';
    TYpInherit : Result := 'inherit';
  end;
end;

function HtmlDisplay(aDisplay : TYDisplay) : string;
begin
  Result :='';
  case aDisplay of
    TYdNONE : Result := 'none';
    TYdInline : Result := 'inline';
    TYdBlock : Result := 'block';
    TYdInline_Block : Result := 'inline-block';
  end;
end;


function HtmlTextTransform(aTextTransform : TYText_transform) : string;
begin
  Result :='';
  case aTextTransform of
    TYttNONE : Result := 'none';
    TYttCapitalize : Result := 'capitalize';
    TYttUppercase : Result := 'uppercase';
    TYttLowerCase : Result := 'lowercase';
    TYttInherit : Result := 'inherit';
    TYttInitial : Result := 'initial';
  end;
end;
procedure Register;
begin
  {$I yclass_icon.lrs}
  RegisterComponents('YHTML',[TYClass]);
end;

end.
