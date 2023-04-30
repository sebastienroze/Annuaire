unit YHtmlControl;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, ExtCtrls, YClass, Controls;

const
  CYHostServerURL = 'http://localhost/';
  CYURIView = 'view';
  CYURIFile = 'file';

  CsFocusOutlineStyle = '2px solid blue';
type

  { TYHtmlControl }

  TYHtmlEvent = procedure(Sender: TObject) of object;
  TYCustomView = class;
  TYCustomLayout = class;
  TYHtmlComponent = class;
  { TYCustomHtmlComponent }

  { TYHtmlComponent }

  TYHtmlControl = class(TCustomPanel)
  private
    IdeRelX, IdeRelY: integer;
    IdeX: integer;
    IdeY: integer;
    IdeRowHeight: integer;
    fTabOrder : integer;
    function GetGenerate: boolean;
    function GetTabOrder: TTabOrder;
    procedure SetTabOrder(AValue: TTabOrder);
    procedure IdeCalcRel;
    procedure htmlalign;
    procedure resetbound;
    function IdeYStyle: integer;
    function IdeXStyle: integer;
    procedure UpdateIdeStyleParent;
    procedure iniOrders;
  protected
    fClass: TYClass;
    fClassMulti: string;
    BrBefore, BrAfter: boolean;
    fHtmlStyle: TYHtmlStyle;
    fLayout: TYCustomLayout;
    fHtmlOrder: integer;
    bfrozen: boolean;
    IdeStyle: TYHtmlStyle;
    fUseControlWidth: boolean;
    fUseControlHeight: boolean;
    fUseControlLeft: boolean;
    fUseControlTop: boolean;
    fText: string;
    fGenerate: boolean;
    procedure Loaded; override;
    function GetfText: string; virtual;
    procedure SetfText(AValue: string); virtual;
    procedure SetHtmlOrder(aHtmlOrder: integer);
    procedure UseControlDesign; virtual;
  public
    InternalScript: string;
    InternalScriptBrowserResize: string;
    FocusEnabled: boolean;
    UseFocusKeys: boolean;
    NoticeBrowserResize : boolean;
    constructor Create(TheOwner: TComponent); override;
    function YInnerName : string;virtual;
    procedure Paint; override;
    procedure SetBounds(aLeft, aTop, aWidth, aHeight: integer); override;
    destructor Destroy; override;
    procedure UpdateIdeStyle;
    procedure PutUseControlWidth(aValue: boolean); virtual;
    procedure PutUseControlHeight(aValue: boolean); virtual;
    procedure PutUseControlTop(aValue: boolean); virtual;
    procedure PutUseControlLeft(aValue: boolean); virtual;
    procedure FillFromRequest(ARequestContent: TStrings; var {%H-}vOnClick: TYHtmlEvent;
      var Sender: TObject; {%H-}YHTMLEXIT: string;var {%H-}ErrorMessage : string); virtual;
    function YHTML: string; virtual;
    function Yscript: string; virtual;
    function Yscript_browserResize: string; virtual;
    function Yscript_mousemove: string; virtual;
    function Yscript_touchmove: string; virtual;
    function Yscript_mouseup: string; virtual;
    function Yscript_touchend: string; virtual;
    function Yscript_keydown: string; virtual;
    function EncodeHtmlClassStyle: string;
    function JVS_getElementById: string;
    function JVS_ParentForm: string;
    function JVS_getElementByInnerId: string;
    function FindConParent: TWinControl;
    function FindWinParent: TWinControl;
    function FindViewParent: TWinControl;
    procedure AddCss({%H-}Lines: TStrings); virtual;
    function FullTabOrder : string;
  published
    property Text: string read GetfText write SetfText;
    property Generate: boolean read GetGenerate write fGenerate;
    property UseDesignerWidth: boolean read fUseControlWidth write PutUseControlWidth;
    property UseDesignerHeight: boolean read fUseControlHeight
      write PutUseControlHeight;
    property UseDesignerLeft: boolean read fUseControlLeft write PutUseControlLeft;
    property UseDesignerTop: boolean read fUseControlTop write PutUseControlTop;
    property HtmlOrder: integer read fHtmlOrder write SetHtmlOrder default -1;
    property HtmlStyle: TYHtmlStyle read fHtmlStyle write fHtmlStyle;
    property HtmlClassMulti: string read fClassMulti write fClassMulti;
    property HtmlClass: TYclass read fClass write fClass;
    property Layout: TYCustomLayout read fLayout write fLayout;
    property TabOrder: TTabOrder read GetTabOrder write SetTabOrder default -1;
  end;
  TYScriptPriority = (YspNormal,YspBeforeNormal,YspHigh,YspBeforeHigh);
  TYHtmlComponent = class(TComponent)
  private
    function GetGenerate: boolean;
  protected
    fGenerate: boolean;
    fScriptsPriority : TYScriptPriority;
    fParentView: TYCustomView;
    fParentControl: TYHtmlControl;
  public
    NoticeBrowserResize : boolean;
    constructor Create(TheOwner: TComponent); override;
    function Yscript_browserResize: string; virtual;
    function YScript: string; virtual;
    function JVS_ParentForm: string;
    procedure FillFromRequest({%H-}ARequestContent: TStrings;var{%H-}vOnClick : TYHtmlEvent;
      var Sender: TObject; {%H-}YHTMLEXIT: string); virtual;
  published
    property ParentView: TYCustomView read fParentView write fParentView;
    property ParentControl: TYHtmlControl read fParentControl write fParentControl;
    property Generate: boolean read GetGenerate write fGenerate;
    property ScriptsPriority: TYScriptPriority read fScriptsPriority write fScriptsPriority;
  end;

  TYLink = (TYlLEFT, TYlRight, TYlTop, TYlBottom, TYlWidth, TYlHeight);

  TYCustomLayout = class(TYHtmlComponent)
  private
  protected
    fAlignTop: TYHtmlControl;
    fAlignLeft: TYHtmlControl;
    fAlignRight: TYHtmlControl;
    fAlignBottom: TYHtmlControl;
    fAlignHeight: TYHtmlControl;
    fAlignWidth: TYHtmlControl;

    fLinkTop: TYLink;
    fLinkLeft: TYLink;
    fLinkRight: TYLink;
    fLinkBottom: TYLink;
    fLinkHeight: TYLink;
    fLinkWidth: TYLink;

  public

  published
    property AlignTop: TYHtmlControl read fAlignTop write fAlignTop;
    property AlignLeft: TYHtmlControl read fAlignLeft write fAlignLeft;
    property AlignRight: TYHtmlControl read fAlignRight write fAlignRight;
    property AlignBottom: TYHtmlControl read fAlignBottom write fAlignBottom;
    property AlignHeight: TYHtmlControl read fAlignHeight write fAlignHeight;
    property AlignWidth: TYHtmlControl read fAlignWidth write fAlignWidth;

    property LinkTop: TYLink read fLinkTop write fLinkTop;
    property LinkLeft: TYLink read fLinkLeft write fLinkLeft;
    property LinkRight: TYLink read fLinkRight write fLinkRight;
    property LinkBottom: TYLink read fLinkBottom write fLinkBottom;
    property LinkHeight: TYLink read fLinkHeight write fLinkHeight;
    property LinkWidth: TYLink read fLinkWidth write fLinkWidth;
  end;


  TYCustomView = class(TYHtmlControl)
  public
    YWindowSize : string;
    RefreshParent: boolean;
    RefreshMe: boolean;
  end;

{ TYHtmlComponent }


function GetListHtmlStyles(conParent: TWinControl; HtmlClass: TYClass;
  HtmlClassMulti: string): TStringList;
function Htmlcolor(sColor: string): integer;
function GetYHYMLControls(conparent: TWinControl): TStringList;
function GetYTabOrderControls(conparent: TWinControl): TStringList;
function JVS_GetCoord(aYHtmlControl: TYHtmlControl; Attribute: string;
  var YViewRequired: string): string;
function JVS_SetCoord(aYHtmlControl: TYHtmlControl; Attribute, Value: string;
  var YViewRequired: string): string;


implementation

uses LCLType, PropEdits, Forms, strprocs, YHtmlDocument, YView, YDbGrid ;



function JVS_SetCoord(aYHtmlControl: TYHtmlControl; Attribute, Value: string;
  var YViewRequired: string): string;
var
  myCtrl: TControl;
  stmp, sPosYView: string;
  LPosYView: TStringList;
  i: integer;
begin
  Result := 'getElementById("id' + aYHtmlControl.Name + '").style.' +
    Attribute + ' = ' + Value;
  stmp := '';
  myCtrl := aYHtmlControl;
  LPosYView := TStringList.Create;
  while not (myCtrl is TForm) do
  begin
    myCtrl := myCtrl.Parent;
//    if myCtrl is TYDbGrid then if TYDbGrid(myCtrl).UseYView = false then myCtrl := myCtrl.Parent;
    if myCtrl is TYView then
    begin
      if pos(myCtrl.Name + '_loaded', YViewRequired) = 0 then
      begin
        if YViewRequired <> '' then
          YViewRequired := YViewRequired + ' && ';
        YViewRequired := YViewRequired + '(' + myCtrl.Name + '_loaded == 1)';
      end;
      sPosYView := 'getElementById("id' + myCtrl.Name + '").contentDocument.';
      sTmp := sPosYView + sTmp;
      for i := 0 to LPosYView.Count - 1 do
        LPosYView.Strings[i] := sPosYView + LPosYView.Strings[i];
      LPosYView.Add('getElementById("id' + myCtrl.Name + '").' +
        'getBoundingClientRect().left');
    end;
  end;
  sPosYView := '';
  for i := 0 to LPosYView.Count - 1 do
    sPosYView := sPosYView + '-document.' + LPosYView.Strings[i];
  Result := 'document.' + sTmp + Result + sPosYView + '+"px";';
  LPosYView.Free;
end;

function JVS_GetCoord(aYHtmlControl: TYHtmlControl; Attribute: string;
  var YViewRequired: string): string;
var
  myCtrl: TControl;
  stmp, sPosYView: string;
  LPosYView: TStringList;
  i: integer;
begin
  Result := 'getElementById("id' + aYHtmlControl.Name + '").getBoundingClientRect().' + Attribute;
  if (aYHtmlControl is TYDbGrid ) then
  begin
    if TYDbGrid(aYHtmlControl).UseYView = true then
    begin
      if Attribute = 'top' then Result := 'getElementById("id' + aYHtmlControl.Name + '").offsetTop';
      if Attribute = 'left' then Result := 'getElementById("id' + aYHtmlControl.Name + '").offsetLeft';
    end;
  end;
  stmp := '';
  myCtrl := aYHtmlControl;
  LPosYView := TStringList.Create;
  while not (myCtrl is TForm) do
  begin
    myCtrl := myCtrl.Parent;
    if myCtrl is TYDbGrid then if TYDbGrid(myCtrl).UseYView = false then myCtrl := myCtrl.Parent;
    if myCtrl is TYCustomView then
    begin
      if pos(myCtrl.Name + '_loaded', YViewRequired) = 0 then
      begin
        if YViewRequired <> '' then
          YViewRequired := YViewRequired + ' && ';
        YViewRequired := YViewRequired + '(' + myCtrl.Name + '_loaded == 1)';
      end;
      sPosYView := 'getElementById("id' + myCtrl.Name + '").contentDocument.';
      sTmp := sPosYView + sTmp;
      for i := 0 to LPosYView.Count - 1 do
        LPosYView.Strings[i] := sPosYView + LPosYView.Strings[i];
      LPosYView.Add('getElementById("id' + myCtrl.Name + '").' +
        'getBoundingClientRect().left+');
    end;
  end;
  sPosYView := '';
  for i := 0 to LPosYView.Count - 1 do
    sPosYView := sPosYView + 'document.' + LPosYView.Strings[i];
  Result := 'document.' + sTmp + Result;
  Result := sPosYView + Result;
  LPosYView.Free;
end;


function GetYHYMLControls(conparent: TWinControl): TStringList;
var
  i: integer;
  cpnhtmlorder: string;
begin
  Result := TStringList.Create;
  for i := 0 to conparent.ControlCount - 1 do
  begin
    if conparent.Controls[i] is TYHtmlControl then
    begin
      cpnhtmlorder := IntToStr(TYHtmlControl(conparent.Controls[i]).HtmlOrder);
      while Length(cpnhtmlorder) < 6 do
        cpnhtmlorder := '0' + cpnhtmlorder;
      Result.AddObject(cpnhtmlorder, conparent.Controls[i]);
    end;
  end;
  Result.Sort;
end;

function GetYTabOrderControls(conparent: TWinControl): TStringList;
var
  i: integer;
  cpntaborder: string;
begin
  Result := TStringList.Create;
  for i := 0 to conparent.ControlCount - 1 do
  begin
    if conparent.Controls[i] is TYHtmlControl then
    begin
      cpntaborder := IntToStr(TYHtmlControl(conparent.Controls[i]).TabOrder);
      while Length(cpntaborder) < 6 do
        cpntaborder := '0' + cpntaborder;
      Result.AddObject(cpntaborder, conparent.Controls[i]);
    end;
  end;
  Result.Sort;
end;

function Htmlcolor(sColor: string): integer;
var
  Prefixe: string;
begin
  Prefixe := '';
{   if LowerCase(copy(sColor,1,5)) = 'light' then
   begin
     system.Delete(sColor,1,5);
     Prefixe := 'Lt';
   end; }
  Result := 0;
  if Copy(sColor, 1, 1) = '#' then
    Result := TColor(ValInt('0x' + Copy(sColor, 6, 2) + Copy(sColor, 4, 2) + Copy(sColor, 2, 2)))
  else
  begin
    if LowerCase(sColor) = 'lightgray' then
      Result := TColor($C0C0C0);
    if Result = 0 then
    begin
      sColor := UpperCase(copy(sColor, 1, 1)) + LowerCase(sColor);
      system.Delete(sColor, 2, 1);
      sColor := Prefixe + sColor;
      try
        Result := StringToColor('Cl' + sColor);
      except
      end;
    end;
  end;
end;

function GetListHtmlStyles(conParent: TWinControl; HtmlClass: TYClass;
  HtmlClassMulti: string): TStringList;
var
  sclasses: string;
  aClass: TYClass;
  htmldoc: TYHtmlDocument;
  i: integer;
  winparent: TControl;
begin
  Result := TStringList.Create;
  sclasses := HtmlClassMulti;
  if conParent is TForm then
  begin
    for i := 0 to conParent.ComponentCount - 1 do
    begin
      if conParent.Components[i] is TYHtmlDocument then
      begin
        htmldoc := TYHtmlDocument(conParent.Components[i]);
        sclasses := sclasses + ' ' + htmldoc.HtmlClassMulti;
        if Assigned(htmldoc.HtmlClass) then
          Result.AddObject('', htmldoc.HtmlClass.HtmlStyle);
        // sclasses := sclasses+' '+ htmldoc.HtmlClass.Name;
        Result.AddObject('', htmldoc.HtmlStyle);
      end;
    end;
    winparent := conParent;
  end
  else
  begin
    if (conParent is TYHtmlControl) then
      winparent := TYHtmlControl(conParent).FindWinParent
    else
      winparent := conParent;
  end;
  if Assigned(HtmlClass) then
    Result.AddObject('', HtmlClass.HtmlStyle);
  for i := 0 to winparent.ComponentCount - 1 do
  begin
    if winparent.Components[i] is TYClass then
    begin
      aClass := TYClass(winparent.Components[i]);
      if pos(aClass.Name + ' ', sclasses + ' ') > 0 then
      begin
        Result.AddObject('', aClass.HtmlStyle);
      end;
    end;
  end;
end;

{ TYHtmlComponent }

function TYHtmlComponent.GetGenerate: boolean;
begin
  Result := fGenerate;
  if (not (csDesigning in ComponentState)) and (not (csLoading in ComponentState)) then
  if Result = true then
    if Assigned(ParentControl) then result := ParentControl.Generate;
end;

constructor TYHtmlComponent.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  fParentView := nil; fParentControl := nil;
  fGenerate := True;
  NoticeBrowserResize :=false;
end;

function TYHtmlComponent.Yscript_browserResize: string;
begin
  Result := '';
end;

function TYHtmlComponent.YScript: string;
begin
  Result := '';
end;

function TYHtmlComponent.JVS_ParentForm: string;
begin
  Result := '';
  if Assigned(fParentView) then
    Result := 'parent.'+TYCustomView(fParentView).JVS_ParentForm;
end;

procedure TYHtmlComponent.FillFromRequest(ARequestContent: TStrings;
  var vOnClick: TYHtmlEvent; var Sender: TObject; YHTMLEXIT: string);
begin

end;

{ TYHtmlControl }

constructor TYHtmlControl.Create(TheOwner: TComponent);

begin
  inherited Create(TheOwner);
  IdeX := 0;
  IdeY := 0;
  IdeRowHeight := 0;
  IdeRelX := 0;
  IdeRelY := 0;

  InternalScript:= '';
  InternalScriptBrowserResize:= '';
  NoticeBrowserResize :=false;

  fUseControlHeight := False;
  fUseControlTop := False;
  fUseControlWidth := False;
  fUseControlHeight := False;
  bfrozen := False;
  BrBefore := False;
  BrAfter := False;
  FocusEnabled := False;
  UseFocusKeys := False;
  fGenerate := True;
  fText := '';
  Caption := '';
  fHtmlStyle := TYHtmlStyle.Create;
  if (csDesigning in ComponentState) then
  begin
    IdeStyle := TYHtmlStyle.Create;
    IdeStyle.Clear;
  end
  else
    IdeStyle := nil;

  fHtmlOrder:= -1;
  fTabOrder:= -1;
  //  Self.SetHtmlOrder(65535);
end;

procedure TYHtmlControl.iniOrders;
var i : integer;
   maxHtml,MaxTab : integer;
   ycrtl : TYHtmlControl;
begin
  maxHtml:= -1;MaxTab := -1;
  if (csDesigning in ComponentState) and (Assigned(Parent) ) then
  begin
    for i := 0 to Parent.ControlCount -1 do
    begin
      if Parent.Controls[i] is TYHtmlControl then
      begin
          ycrtl := TYHtmlControl(Parent.Controls[i]);
          if maxHtml < ycrtl.fHtmlOrder then maxHtml :=  ycrtl.fHtmlOrder;
          if maxTab < ycrtl.fTabOrder then maxTab :=  ycrtl.fTabOrder;
      end;
    end;
//    if self.fHtmlOrder = -1 then
    self.fHtmlOrder := maxHtml+1;
//    if self.fTabOrder = -1 then
    self.TabOrder := maxTab+1;
//    self.htmlalign();
//    self.resetbound();
    //    Repaint;
  end;
end;


procedure TYHtmlControl.Loaded;
begin
  inherited Loaded;
  if (csDesigning in ComponentState) then
  begin
    self.htmlalign();
    self.resetbound();
  end;
end;


procedure TYHtmlControl.SetfText(AValue: string);
begin
  fText := AValue;
end;

function TYHtmlControl.GetfText: string;
begin
  Result := fText;
end;

procedure TYHtmlControl.SetHtmlOrder(aHtmlOrder: integer);
var
  i: integer;
  conparent: TWinControl;
  YCpn: TYHtmlControl;
begin
  if (csDesigning in ComponentState) and (not (csLoading in ComponentState)) then
  begin
    conparent := self.FindConParent;
    if assigned(conparent) then
    begin
      fHtmlOrder := 65535;
      with GetYHYMLControls(conparent) do
        try
          if aHtmlOrder < 0 then
            aHtmlOrder := 0;
          if aHtmlOrder > Count - 1 then
            aHtmlOrder := Count - 1;
          for i := 0 to Count - 2 do
          begin
            YCpn := TYHtmlControl(Objects[i]);
            if (i < aHtmlOrder) then
              YCpn.fHtmlOrder := i
            else
              YCpn.fHtmlOrder := i + 1;
          end;
        finally
          Free;
        end;
      fHtmlOrder := aHtmlOrder;
    end;
    self.htmlalign();
    self.resetbound();
    //    Repaint;
  end
  else
    fHtmlOrder := aHtmlOrder;
end;


procedure TYHtmlControl.Paint;
var
  scolor: string;
begin
  if (csDesigning in ComponentState) then
  begin
    IdeStyle.Clear;
    UpdateIdeStyle;
    Canvas.Font.Color := clBlack;
    Canvas.Brush.Color := clWhite;
    scolor := IdeStyle.font_color;
    if scolor <> '' then
    begin
      Canvas.Pen.Color := Htmlcolor(scolor);
      Canvas.Font.Color := Canvas.Pen.Color;
    end;
    scolor := IdeStyle.background_color;
    if scolor <> '' then
      Canvas.Brush.Color := Htmlcolor(scolor);
  end;
end;

procedure TYHtmlControl.SetBounds(aLeft, aTop, aWidth, aHeight: integer);
var
  NewHtmlorder: integer;
  conparent: TWinControl;
  i: integer;
  YCpn: TYHtmlControl;
  minWidth: integer;
begin
  if (not Assigned(IdeStyle)) then
  begin
    inherited SetBounds(aLeft, aTop, aWidth, aHeight);
    exit;
  end;
  if ((csDesigning in ComponentState) and (not (csLoading in ComponentState)))  then
  begin
    if (bfrozen = False) and ((IdeStyle.position = TYpSTATIC) or (IdeStyle.position = TYpRelative)) then
    begin
      if ((Self.Left <> aLeft) or (Self.Top <> aTop)) then
      begin
        conparent := self.FindConParent;
        if assigned(conparent) then
          with GetYHYMLControls(conparent) do
          begin
            NewHtmlorder := 0;
            for i := 0 to Count - 1 do
            begin
              YCpn := TYHtmlControl(Objects[i]);
              if (YCpn <> self) and (NewHtmlorder <= YCpn.HtmlOrder) and
                ((YCpn.IdeStyle.position = TYpSTATIC) or (YCpn.IdeStyle.position = TYpRelative)) then
              begin
                minWidth := YCpn.Width;
                if Width < minWidth then
                  minWidth := Width;
                if (YCpn.IdeY <= (aTop - IdeRelY)) and
                  (YCpn.IdeX <= (aLeft - IdeRelX)) then
                  NewHtmlorder := YCpn.HtmlOrder;
                if ((YCpn.IdeY + YCpn.IdeRowHeight) <= (aTop - IdeRelY)) or
                  ((YCpn.IdeY <= (aTop - IdeRelY)) and
                  ((YCpn.IdeX + minWidth) <= (aLeft - IdeRelX))) then
                  NewHtmlorder := YCpn.HtmlOrder + 1;
              end;
            end;
            self.HtmlOrder := NewHtmlorder;
          end;
      end;
      if (Self.Width <> aWidth) or (Self.Height <> aHeight) or
        (Self.Top <> aTop) or (Self.Left <> aLeft) then
      begin
        inherited SetBounds(aLeft, aTop, aWidth, aHeight);
        Repaint;
        self.htmlalign();
        self.resetbound();
      end;
    end
    else if (bfrozen = False) and (IdeStyle.position = TYpAbsolute) then
    begin
      if (Self.Width <> aWidth) or (Self.Height <> aHeight) or
        (Self.Top <> aTop) or (Self.Left <> aLeft) then
      begin
        inherited SetBounds(aLeft, aTop, aWidth, aHeight);
        UseControlDesign;
        UpdateIdeStyle;
        self.htmlalign();
        self.resetbound();
        Repaint;
      end;
    end
    else inherited SetBounds(aLeft, aTop, aWidth, aHeight);
    if not (csLoading in ComponentState) then UseControlDesign;
  end
  else inherited SetBounds(aLeft, aTop, aWidth, aHeight);
end;


procedure TYHtmlControl.UpdateIdeStyleParent;
var
  conParent: TWinControl;
  i: integer;
begin
  conParent := FindConParent;
  if conParent is TForm then
  begin
    IdeStyle.Clear;
    with GetListHtmlStyles(conParent, HtmlClass, HtmlClassMulti) do
      try
        for i := 0 to Count - 1 do
        begin
          IdeStyle.AddHtmlStyle(TYHtmlStyle(Objects[i]));
        end;
      finally
        Free;
      end;
  end;
  if conParent is TYHtmlControl then
  begin
    TYHtmlControl(conParent).UpdateIdeStyleParent;
    IdeStyle.AddHtmlStyle(TYHtmlControl(conParent).IdeStyle);
    with GetListHtmlStyles(conParent, HtmlClass, HtmlClassMulti) do
      try
        for i := 0 to Count - 1 do
        begin
          IdeStyle.AddHtmlStyle(TYHtmlStyle(Objects[i]));
        end;
      finally
        Free;
      end;
  end;
end;

procedure TYHtmlControl.UpdateIdeStyle;
//var conParent : TWinControl;
//  i : integer;
begin
  UpdateIdeStyleParent;
{  conParent := FindConParent;
  if conParent is TForm then
  begin
      IdeStyle.Clear;
      with GetListHtmlStyles(conParent,HtmlClass, HtmlClassMulti) do
      try
         for i := 0 to Count -1 do
         begin
            IdeStyle.AddHtmlStyle(TYHtmlStyle(Objects[i]));
         end;
      finally
         free;
      end;
  end;
  if conParent is TYHtmlControl then
  begin
     TYHtmlControl(conParent).UpdateIdeStyleParent;
     IdeStyle.AddHtmlStyle(TYHtmlControl(conParent).IdeStyle);
     with GetListHtmlStyles(conParent,HtmlClass, HtmlClassMulti) do
     try
        for i := 0 to Count -1 do
        begin
           IdeStyle.AddHtmlStyle(TYHtmlStyle(Objects[i]));
        end;
     finally
        free;
     end;
  end;    }
  IdeStyle.AddHtmlStyle(Self.fHtmlStyle);
  IdeStyle.font_size := IdeStyle.font_size;//(IdeStyle.font_size*133) div 100;
  if IdeStyle.font_size = 0 then
    IdeStyle.font_size := 12;
end;

procedure TYHtmlControl.PutUseControlWidth(aValue: boolean);
begin
  if (aValue <> fUseControlWidth) then
  begin
    fUseControlWidth := aValue;
    if  (csDesigning in ComponentState) and (not (csLoading in ComponentState)) then
    begin
      if (aValue = True) then
        UseControlDesign;
      if (aValue = False) then
      begin
        fHtmlStyle.position_width := '';
        SetBounds(Left, Top, Width, Height);
      end;
    end;
  end;
end;

procedure TYHtmlControl.PutUseControlHeight(aValue: boolean);
begin
  if (aValue <> fUseControlHeight) then
  begin
    fUseControlHeight := aValue;
    if  (csDesigning in ComponentState) and (not (csLoading in ComponentState)) then
    begin
      if (aValue = True) then
        UseControlDesign;
      if (aValue = False) then
      begin
        fHtmlStyle.position_height := '';
        SetBounds(Left, Top, Width, Height);
      end;
    end;
  end;
end;

procedure TYHtmlControl.PutUseControlTop(aValue: boolean);
begin
//  if (aValue <> fUseControlTop)then
  begin
    fUseControlTop := aValue;
    if  (csDesigning in ComponentState) then //and (not (csLoading in ComponentState))
    begin
      if (aValue = True) then
        UseControlDesign;
      if (aValue = False) then
      begin
        fHtmlStyle.position_top := '';
        if (fHtmlStyle.position = TYpAbsolute) and (fUseControlLeft = False) then
          fHtmlStyle.position := TYpSTATIC;
      end;
      UpdateIdeStyle;
      if (not (csLoading in ComponentState)) then
      begin
      self.htmlalign();
      self.resetbound();
      end;
      //    Repaint;
    end;
  end;
//  if  Assigned(IdeStyle) and (aValue = true) and  (csDesigning in ComponentState) and (csLoading in ComponentState) then IdeStyle.position:=TYpAbsolute;
end;

procedure TYHtmlControl.PutUseControlLeft(aValue: boolean);
begin
//  if (aValue <> fUseControlLeft) then
  begin
    fUseControlLeft := aValue;
    if  (csDesigning in ComponentState) then  // and (not (csLoading in ComponentState))
    begin
      if (aValue = True) then
        UseControlDesign;
      if (aValue = False) then
      begin
        fHtmlStyle.position_left := '';
        if (fHtmlStyle.position = TYpAbsolute) and (fUseControlTop = False) then
          fHtmlStyle.position := TYpSTATIC;
      end;
      UpdateIdeStyle;
      if (not (csLoading in ComponentState)) then
      begin
      self.htmlalign();
      self.resetbound();
      end;
    end;
//    if  (csDesigning in ComponentState) and (csLoading in ComponentState) then fIdeStyle.position:=fHtmlStyle.position;
    //    Repaint;
  end;
  if  Assigned(IdeStyle) and (aValue = true) and  (csDesigning in ComponentState) and (csLoading in ComponentState) then IdeStyle.position:=TYpAbsolute;
end;

procedure TYHtmlControl.UseControlDesign;
begin
  if fUseControlWidth = True then
    HtmlStyle.position_width := IntToStr(Width) + 'px';
  if fUseControlHeight = True then
    HtmlStyle.position_height := IntToStr(Height) + 'px';
  if fUseControlTop = True then
    HtmlStyle.position_top := IntToStr(Top) + 'px';
  if fUseControlLeft = True then
    HtmlStyle.position_left := IntToStr(Left) + 'px';
  if (fUseControlTop = True) or (fUseControlLeft = True) then
  begin
    if (IdeStyle.position <> TYpAbsolute) then fHtmlStyle.position := TYpAbsolute;
  end;
end;

function TYHtmlControl.YInnerName: string;
begin
  result:= Self.Name;
end;

destructor TYHtmlControl.Destroy;
begin
  inherited Destroy;
end;


procedure TYHtmlControl.IdeCalcRel;
var
  Backup: integer;
begin
  if IdeStyle.position = TYpRelative then
  begin
    Backup := IdeX;
    IdeX := 0;
    IdeRelX := IdeXStyle;
    IdeX := Backup;
    Backup := IdeY;
    IdeY := 0;
    IdeRelY := IdeYStyle;
    IdeY := Backup;
  end
  else
  begin
    IdeRelX := 0;
    IdeRelY := 0;
  end;
end;

procedure TYHtmlControl.htmlalign;
var
  i, j: integer;
  xpos, ypos: integer;
  xposleft, xposright: integer;
  conparent: TWinControl;
  MaxHeight: integer;
  irealign: integer;
  YHTMLControl: TYHtmlControl;
  RealignCtrl: TYHtmlControl;
begin
  if (csLoading in ComponentState) or  not (csDesigning in ComponentState) then exit;
  xpos := 0;
  ypos := 0;
  MaxHeight := 0;
  conparent := self.FindConParent;
  if assigned(conparent) then
    with GetYHYMLControls(conparent) do
      try
{    if conparent is TForm then
    begin
      ypos:= TForm(conparent).VertScrollBar.Position;
    end;      }
        irealign := 0;
        xposleft := 0;
        xposright := conparent.Width;
        for i := 0 to Count - 1 do
        begin
          YHTMLControl := TYHtmlControl(TYHtmlControl(Objects[i]));
          if (YHTMLControl.IdeStyle.position = TYpSTATIC) or
            (YHTMLControl.IdeStyle.position = TYpRelative) then
          begin
            if YHTMLControl.BrBefore = True then
            begin
              xpos := 0;
              ypos := ypos + MaxHeight;
              for j := irealign to i do
              begin
                RealignCtrl := TYHtmlControl(TYHtmlControl(Objects[j]));
                RealignCtrl.IdeRowHeight := MaxHeight;
                if (RealignCtrl.IdeStyle.float <> TYfLeft) and
                  (RealignCtrl.IdeStyle.float <> TYfRight) then
                begin
                  RealignCtrl.IdeX := RealignCtrl.IdeX + xposleft;
                end;
                //               TYHtmlControl(TYHtmlControl(Objects[j])).IdeY := (ypos - TYHtmlControl(Objects[j]).Height);
              end;
              MaxHeight := 0;
              irealign := i;
              xposleft := 0;
              xposright := conparent.Width;
            end;
            if YHTMLControl.IdeStyle.float = TYfLeft then
              YHTMLControl.IdeX := xposleft
            else if YHTMLControl.IdeStyle.float = TYfRight then
              YHTMLControl.IdeX := xposright - YHTMLControl.Width
            else
              YHTMLControl.IdeX := xpos;
            YHTMLControl.IdeY := ypos;
            YHTMLControl.IdeCalcRel;
            if (MaxHeight < YHTMLControl.Height) then
              MaxHeight := YHTMLControl.Height;
            if YHTMLControl.BrAfter = True then
            begin
              xpos := 0;
              ypos := ypos + MaxHeight;
              for j := irealign to i do
              begin
                RealignCtrl := TYHtmlControl(TYHtmlControl(Objects[j]));
                RealignCtrl.IdeRowHeight := MaxHeight;
                if (RealignCtrl.IdeStyle.float <> TYfLeft) and
                  (RealignCtrl.IdeStyle.float <> TYfRight) then
                begin
                  RealignCtrl.IdeX := RealignCtrl.IdeX + xposleft;
                end;
                //             TYHtmlControl(TYHtmlControl(Objects[j])).IdeY := (ypos - TYHtmlControl(Objects[j]).Height);
              end;
              MaxHeight := 0;
              xposright := conparent.Width;
              xposleft := 0;
              irealign := i + 1;
            end
            else
            begin
              if YHTMLControl.IdeStyle.float = TYfLeft then
                xposleft := xposleft + YHTMLControl.Width
              else if YHTMLControl.IdeStyle.float = TYfRight then
                xposright := xposright - YHTMLControl.Width
              else
                xpos := xpos + YHTMLControl.Width;
            end;
          end
          else
          begin
            if (YHTMLControl.IdeStyle.position = TYpAbsolute) then
            begin
              YHTMLControl.IdeX := xpos;
              YHTMLControl.IdeY := ypos;
              YHTMLControl.IdeX := YHTMLControl.IdeXStyle;
              YHTMLControl.IdeY := YHTMLControl.IdeYStyle;
              YHTMLControl.IdeRelX := 0;
              YHTMLControl.IdeRelY := 0;
            end
            else
            begin
              YHTMLControl.IdeX := YHTMLControl.Left;
              YHTMLControl.IdeY := YHTMLControl.Top;
              YHTMLControl.IdeRelX := 0;
              YHTMLControl.IdeRelY := 0;
            end;
            //        YHTMLControl.IdeRowHeight:=YHTMLControl.Height;
          end;
        end;
        ypos := ypos + MaxHeight;
        for j := irealign to i do
        begin
          RealignCtrl := TYHtmlControl(TYHtmlControl(Objects[j]));
          RealignCtrl.IdeRowHeight := MaxHeight;
          if (RealignCtrl.IdeStyle.float <> TYfLeft) and
            (RealignCtrl.IdeStyle.float <> TYfRight) then
          begin
            RealignCtrl.IdeX := RealignCtrl.IdeX + xposleft;
          end;
          //      TYHtmlControl(TYHtmlControl(Objects[j])).IdeY := (ypos - TYHtmlControl(Objects[j]).Height);
        end;
        //    if self.HtmlOrder = 65535 then self.SetHtmlOrder(65535);
        //    xhtmlresetbound(self);
      finally
        Free;
      end;
end;

procedure TYHtmlControl.resetbound;
var
  i: integer;
  winparent: TWinControl;
  ycon: TYHtmlControl;
  Posy: integer;
begin
//  if (csLoading in ComponentState) or not (csDesigning in ComponentState) then exit;
//  UpdateIdeStyle;
  winparent := self.FindWinParent;
  if assigned(winparent) then
    for i := 0 to winparent.ComponentCount - 1 do
    begin
      if winparent.Components[i] is TYHtmlControl then
      begin
        ycon := TYHtmlControl(winparent.Components[i]);
        if ycon.bfrozen = False then
        begin
          ycon.bfrozen := True;
          Posy := ycon.IdeY;
          if (ycon.IdeStyle.position = TYpSTATIC) or
            (ycon.IdeStyle.position = TYpRelative) then
            Posy := Posy + ycon.IdeRowHeight - ycon.Height;
          ycon.SetBounds(ycon.IdeX + ycon.IdeRelX, Posy +
            ycon.IdeRelY, ycon.Width, ycon.Height);
          ycon.bfrozen := False;
        end;
      end;
    end;
end;

function TYHtmlControl.IdeXStyle: integer;
var
  sValue, sUnit: string;
begin
  Result := IdeX;
  sUnit := Self.IdeStyle.position_right;
  sValue := StrTokenNumAlpha(sUnit);
  if LowerCase(sUnit) = 'px' then
    Result := Self.FindWinParent.Width - ValInt(sValue) - Self.Width;
  if LowerCase(sUnit) = '%' then
    Result := Self.FindWinParent.Width - ((Self.FindWinParent.Width * ValInt(sValue)) div
      100) - Self.Width;

  sUnit := Self.IdeStyle.position_left;
  sValue := StrTokenNumAlpha(sUnit);
  if LowerCase(sUnit) = 'px' then
    Result := ValInt(sValue);
  if LowerCase(sUnit) = '%' then
    Result := (Self.FindWinParent.Width * ValInt(sValue)) div 100;
end;

function TYHtmlControl.IdeYStyle: integer;
var
  sValue, sUnit: string;
begin
  Result := IdeY;
  sUnit := Self.IdeStyle.position_bottom;
  sValue := StrTokenNumAlpha(sUnit);
  if LowerCase(sUnit) = 'px' then
    Result := Self.FindWinParent.Height - ValInt(sValue) - Self.Height;
  if LowerCase(sUnit) = '%' then
    Result := Self.FindWinParent.Height -
      ((Self.FindWinParent.Height * ValInt(sValue)) div 100) - Self.Height;
  ;

  sUnit := Self.IdeStyle.position_top;
  sValue := StrTokenNumAlpha(sUnit);
  if LowerCase(sUnit) = 'px' then
    Result := ValInt(sValue);
  if LowerCase(sUnit) = '%' then
    Result := (Self.FindWinParent.Height * ValInt(sValue)) div 100;

end;

procedure TYHtmlControl.FillFromRequest(ARequestContent: TStrings;
  var vOnClick: TYHtmlEvent; var Sender: TObject; YHTMLEXIT: string;var ErrorMessage : string);
begin
  if Self.Generate = false then exit;
  if ARequestContent.IndexOfName(Name) >= 0 then
    Text := ARequestContent.Values[Name];
end;

function TYHtmlControl.YHTML: string;
begin
  Result := '';
end;

function TYHtmlControl.Yscript: string;
begin
  Result := '';
end;

function TYHtmlControl.Yscript_browserResize: string;
begin
  Result := '';
end;

function TYHtmlControl.Yscript_mousemove: string;
begin
  Result := '';
end;

function TYHtmlControl.Yscript_touchmove: string;
begin
  Result := '';
end;

function TYHtmlControl.Yscript_mouseup: string;
begin
  Result := '';
end;

function TYHtmlControl.Yscript_touchend: string;
begin
  Result := '';
end;

function TYHtmlControl.Yscript_keydown: string;
begin
  Result := '';
end;

function TYHtmlControl.EncodeHtmlClassStyle: string;
begin
  Result := EncodeYHtmlClass(HtmlClass, fClassMulti) + fHtmlStyle.EncodeHtmlStyle;
end;

function TYHtmlControl.JVS_getElementById: string;
var
  myCtrl: TWinControl;
begin
  Result := 'document.getElementById("id' + Name + '")';
  myCtrl := self.Parent;
  while not (myCtrl is TForm) do
  begin
    if myCtrl is TYView then
    begin
      Result := 'document.getElementById("id' + myCtrl.Name + '").contentWindow.' + Result;
    end;
    myCtrl := myCtrl.Parent;
  end;
end;

function TYHtmlControl.JVS_getElementByInnerId: string;
var
  myCtrl: TWinControl;
begin
  Result := 'document.getElementById("id' + YInnerName + '")';
  myCtrl := self.Parent;
  while not (myCtrl is TForm) do
  begin
    if myCtrl is TYView then
    begin
      Result := 'document.getElementById("id' + myCtrl.Name + '").contentWindow.' + Result;
    end;
    myCtrl := myCtrl.Parent;
  end;
end;

function TYHtmlControl.JVS_ParentForm: string;
var
  myCtrl: TWinControl;
begin
  Result := '';
  myCtrl := self;
  if (myCtrl is TYView) then myCtrl := Self.Parent;
  while not (myCtrl is TForm) do
  begin
    if not assigned (myCtrl) then
      exit;  // debug
    if myCtrl is TYView then
    begin
      Result := 'parent.' + Result;
    end;
    if myCtrl is TYDbGrid then if TYDbGrid(myCtrl).UseYView then Result := 'parent.' + Result;
    myCtrl := myCtrl.Parent;

  end;
end;


function TYHtmlControl.FindConParent: TWinControl;
var
  bok: boolean;
begin
  Result := nil;
  if Assigned(Parent) then
  begin
    Result := Parent;
    bok := assigned(Result.Parent);
    while bok = True do
    begin
      if (Result is TYHtmlControl) or (Result is TForm) then
        bok := False
      else
      begin
        Result := Result.Parent;
        bok := assigned(Result.Parent);
      end;
    end;
  end;
end;

function TYHtmlControl.FindWinParent: TWinControl;
begin
  Result := Parent;
  while assigned(Result) and not (Result is TForm) do
  begin
    Result := Result.Parent;
  end;
end;

function TYHtmlControl.FindViewParent: TWinControl;
var bfound : boolean;
begin
  bfound := false;
  Result := Parent;
  if Result is TYDbGrid then if TYDbGrid(Result).UseYView = true then bfound := true;
  while assigned(Result) and not (Result is TForm) and not (Result is TYView) and (bfound =false) do
  begin
    Result := Result.Parent;
    if Result is TYDbGrid then if TYDbGrid(Result).UseYView = true then bfound := true;
  end;
end;

procedure TYHtmlControl.AddCss(Lines: TStrings);
begin

end;

function TYHtmlControl.FullTabOrder: string;
begin
  result := StrPad(IntToStr(TabOrder),'0',5);
  if Assigned(parent) then
  if Parent is TYHtmlControl then result := TYHtmlControl(Parent).FullTabOrder+Result;
end;

function TYHtmlControl.GetTabOrder: TTabOrder;
begin
  if fTabOrder = -1 then iniOrders;
  Result := fTabOrder;
end;

function TYHtmlControl.GetGenerate: boolean;
var ConParent : TControl;
begin
  Result := fGenerate;
  if (not (csDesigning in ComponentState)) and (not (csLoading in ComponentState)) then
  if Result = true then
  begin
    ConParent :=FindConParent;
    if ConParent is TYHtmlControl then Result := TYHtmlControl(ConParent).Generate;
  end;
end;

procedure TYHtmlControl.SetTabOrder(AValue: TTabOrder);
var
  i: integer;
  conparent: TWinControl;
  YCpn: TYHtmlControl;
begin
  if (csDesigning in ComponentState) and (not (csLoading in ComponentState)) then
  begin
    conparent := self.Parent;
    if assigned(conparent) then
    begin
      fTabOrder := 65535;
      with GetYTabOrderControls(conparent) do
        try
          if AValue < 0 then
            AValue := 0;
          if AValue > Count - 1 then
            AValue := Count - 1;
          for i := 0 to Count - 2 do
          begin
            YCpn := TYHtmlControl(Objects[i]);
            if (i < AValue) then
              YCpn.fTabOrder := i
            else
              YCpn.fTabOrder := i + 1;
          end;
        finally
          Free;
        end;
    end;
  end;
  fTabOrder := AValue;
  inherited TabOrder:= fTabOrder;
end;

begin
  // Cacher les propriétés inutilisées.
  RegisterPropertyEditor(TypeInfo(TCursor), TYHtmlControl, 'Cursor', THiddenPropertyEditor);
  RegisterPropertyEditor(TypeInfo(TTranslateString), TYHtmlControl,
    'Hint', THiddenPropertyEditor);
  RegisterPropertyEditor(TypeInfo(THelpContext), TYHtmlControl,
    'HelpContext', THiddenPropertyEditor);
  RegisterPropertyEditor(TypeInfo(string), TYHtmlControl, 'HelpKeyword',
    THiddenPropertyEditor);
  RegisterPropertyEditor(TypeInfo(THelpType), TYHtmlControl, 'HelpType',
    THiddenPropertyEditor);

  RegisterPropertyEditor(TypeInfo(TAlign), TYHtmlControl, 'Align', THiddenPropertyEditor);
  RegisterPropertyEditor(TypeInfo(TAlignment), TYHtmlControl, 'Alignment',
    THiddenPropertyEditor);
  RegisterPropertyEditor(TypeInfo(TAnchors), TYHtmlControl, 'Anchors',
    THiddenPropertyEditor);
  RegisterPropertyEditor(TypeInfo(boolean), TYHtmlControl, 'AutoSize',
    THiddenPropertyEditor);

  (*in Delphi, call UnlistPublishedProperty() from the DesignIntf unit.*)
  (*in Lazarus, call RegisterPropertyEditor() from the PropEdits unit.*)

end.
