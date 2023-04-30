unit YScrollbar;

{$mode objfpc}{$H+}

interface

uses
  YHtmlControl,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;

type

  { TYScrollbar }

  TYScrollbar = class(TYHtmlControl)
  private
    fOnClickScroll,fOnClickFirst,fOnClickLast,fOnClickPrior,fOnClickNext,fOnClickPriorPG,fOnClickNextPG : TYHtmlEvent;
    fVertical : boolean;
    fPageSizePercent : integer;
    fMaxValue : integer;
    fTargetView : TYCustomView;
    procedure SetVertical(AValue: Boolean);
  protected

  public
    InternalButtonPosition:string;
    constructor Create(TheOwner: TComponent);override;
    procedure Paint; override;
    function YHTML: string;override;
    function Yscript : string; override;
    function YScript_browserResize : string;override;
    function Yscript_mousemove : string;override;
    function Yscript_touchmove : string;override;
    function Yscript_mouseup : string;override;
    function Yscript_touchend : string;override;
    procedure FillFromRequest(ARequestContent : TStrings; var vOnClick : TYHtmlEvent;var Sender:TObject;YHTMLEXIT : string;var ErrorMessage : string);override;
  published
    property OnClickScroll: TYHtmlEvent read fOnClickScroll write fOnClickScroll;
    property OnClickFirst: TYHtmlEvent read fOnClickFirst write fOnClickFirst;
    property OnClickLast: TYHtmlEvent read fOnClickLast write fOnClickLast;
    property OnClickPrior: TYHtmlEvent read fOnClickPrior write fOnClickPrior;
    property OnClickNext: TYHtmlEvent read fOnClickNext write fOnClickNext;
    property OnClickPriorPG: TYHtmlEvent read fOnClickPriorPG write fOnClickPriorPG;
    property OnClickNextPG: TYHtmlEvent read fOnClickNextPG write fOnClickNextPG;
    property Vertical : Boolean read fVertical write SetVertical;
    property MaxValue : integer read fMaxValue write fMaxValue;
    property PageSizePercent : integer read fPageSizePercent write fPageSizePercent;
    property TargetView : TYCustomView read fTargetView write fTargetView;
  end;

procedure Register;

implementation

uses strprocs;

procedure Register;
begin
  {$I yscrollbar_icon.lrs}
  RegisterComponents('YHTML',[TYScrollbar]);
end;

{ TYScrollbar }

procedure TYScrollbar.SetVertical(AValue: Boolean);
begin
  if fVertical=AValue then Exit;
  fVertical:=AValue;
  if  (csDesigning in ComponentState)  then
  begin
    UseDesignerWidth:= true;
    UseDesignerHeight:= true;
    if AValue = true then
    begin
      Width:= 16;
      Height:= 150;
    end
    else
    begin
      Width:= 150;
      Height:= 16;
    end;
  end;
end;

constructor TYScrollbar.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  fText:= '50';
  fMaxValue := 100;
  BrAfter:= true;
  BrBefore:= true;
  InternalButtonPosition := 'position:absolute;';
{  HtmlStyle.background_color:='#CCCCCC';
  HtmlStyle.border_top := '1px solid #EEEEEE';
  HtmlStyle.border_left := '1px solid #EEEEEE';
  HtmlStyle.border_right := '1px solid #AAAAAA';
  HtmlStyle.border_bottom := '1px solid #AAAAAA';  }
  HtmlStyle.cursor:= 'pointer';
  fPageSizePercent:= 0;
end;

procedure TYScrollbar.Paint;
var posx,posy : integer;
begin
  inherited Paint;
  if  (csDesigning in ComponentState)  then
  begin
    Canvas.Rectangle(0,0,Width,Height);
    if Vertical then
    begin
      Canvas.Line(3,Width,Width div 2,3);
      Canvas.Line(Width div 2,3,Width-3,Width);

      Canvas.Line(3,Height-Width,Width div 2,Height-3);
      Canvas.Line(Width div 2,Height-3,Width-3,Height-Width);
    end
    else
    begin
      Canvas.Line(Height,3,3,Height div 2);
      Canvas.Line(3,Height div 2,Height,Height-3);

      Canvas.Line(Width-Height,3,Width-3,Height div 2);
      Canvas.Line(Width-3,Height div 2,Width-Height,Height-3);

    end;
    posx := Width div 2;
    posy := Height div 2;
    Canvas.Line(posx,posy-3,posx+3,posy);
    Canvas.Line(posx+3,posy,posx,posy+3);
    Canvas.Line(posx,posy+3,posx-3,posy);
    Canvas.Line(posx-3,posy,posx,posy-3);

  end;
end;

function TYScrollbar.YHTML: string;
var
   BtnStyle,CursorStyle : string;
   PictureCursor,PictureCursorBack ,
   SvgPrior,SvgNext,SvgFirst,SvgLast : string;
   btnsize,barsize,cursorsize : integer;
   pgpriorsize,pgnextsize : string;
   ssize : string;
begin
  Result := '';
  PictureCursor :=  '<svg width=100% height=100% viewBox="0 0 12 12"><ellipse id="ellipse1" style="fill:#444444;stroke:#888888;stroke-width:1" cx="50%" cy="50%" rx="25%" ry="25%" /></svg>';
  if fVertical = true then
  begin
    ssize := HtmlStyle.position_width;
    btnsize := ValInt(StrTokenNumAlpha(ssize))-2;
    ssize := HtmlStyle.position_height;
    barsize := ValInt(StrTokenNumAlpha(ssize))-2;
    barsize := barsize-(4*btnsize);
    cursorsize := (barsize * fPageSizePercent) div 100;
    if cursorsize<14 then cursorsize:=14;
    barsize := barsize-cursorsize;
    SvgPrior :=  '<svg viewBox="0 0 12 12"><polygon id="polygon1" style="fill:#444444;stroke:#888888;stroke-width:1" points="6,2 10,10 2,10" /></svg>';
    SvgFirst :=  '<svg viewBox="0 0 12 12"><polygon id="polygon2" style="fill:#444444;stroke:#888888;stroke-width:1" points="2,2 10,2 10,4 7,4 10,10 2,10 5,4 2,4" /></svg>';
    SvgNext  :=  '<svg viewBox="0 0 12 12"><polygon id="polygon3" style="fill:#444444;stroke:#888888;stroke-width:1" points="2,2 10,2 6,10" /></svg>';
    SvgLast  :=  '<svg viewBox="0 0 12 12"><polygon id="polygon2" style="fill:#444444;stroke:#888888;stroke-width:1" points="2,10 10,10 10,8 7,8 10,2 2,2 5,8 2,8" /></svg>';
    pgpriorsize := 'style="'+InternalButtonPosition+'background-color:#CCCCCC;width:100%;"';
    pgnextsize  := 'style="'+InternalButtonPosition+'background-color:#CCCCCC;width:100%"';
    BtnStyle    := 'style="'+InternalButtonPosition+'background-color:#AAAAAA;border-top: 1px solid #EEEEEE;border-left: 0px solid #EEEEEE;border-right: 0px solid #888888;border-bottom: 1px solid #888888;"';
    CursorStyle := 'style="'+InternalButtonPosition+'background-color:#AAAAAA;border-top: 1px solid #EEEEEE;border-left: 0px solid #EEEEEE;border-right: 0px solid #888888;border-bottom: 1px solid #888888;"';
  end
  else
  begin
    ssize := HtmlStyle.position_height;
    btnsize := ValInt(StrTokenNumAlpha(ssize))-2;
    ssize := HtmlStyle.position_width;
    barsize := ValInt(StrTokenNumAlpha(ssize))-2;
    barsize := barsize-(4*btnsize);
    cursorsize := (barsize * fPageSizePercent) div 100;
    if cursorsize<14 then cursorsize:=14;
    barsize := barsize-cursorsize;
    SvgPrior :=  '<svg height=100% viewBox="0 0 12 12"><polygon id="polygon1" style="fill:#444444;stroke:#888888;stroke-width:1" points="2,6 10,10 10,2" /></svg>';
    SvgNext :=   '<svg height=100% viewBox="0 0 12 12"><polygon id="polygon3" style="fill:#444444;stroke:#888888;stroke-width:1" points="2,2 2,10 10,6" /></svg>';
    SvgFirst :=  '<svg height=100% viewBox="0 0 12 12"><polygon id="polygon2" style="fill:#444444;stroke:#888888;stroke-width:1" points="2,2 2,10 4,10 4,7 10,10 10,2 4,5 4,2" /></svg>';
    SvgLast :=   '<svg height=100% viewBox="0 0 12 12"><polygon id="polygon2" style="fill:#444444;stroke:#888888;stroke-width:1" points="10,2 10,10 8,10 8,7 2,10 2,2 8,5 8,2" /></svg>';
    pgpriorsize := 'style="'+InternalButtonPosition+'background-color:#CCCCCC;height:100%;"';
    pgnextsize  := 'style="'+InternalButtonPosition+'background-color:#CCCCCC;height:100%;"';
    BtnStyle    := 'style="'+InternalButtonPosition+'background-color:#AAAAAA;border-top: 0px solid #EEEEEE;border-left: 1px solid #EEEEEE;border-right: 1px solid #888888;border-bottom: 0px solid #888888;"';
    CursorStyle := 'style="'+InternalButtonPosition+'background-color:#AAAAAA;border-top: 0px solid #EEEEEE;border-left: 1px solid #EEEEEE;border-right: 1px solid #888888;border-bottom: 0px solid #888888;"';
  end;
  PictureCursorBack := '';
  ssize := intToStr(btnsize);
  Result:= Result+ '<div id="id' +Name +'" '+EncodeHtmlClassStyle+ '>';
  Result:= Result+ '<a id="scrollfirst_' +Name + '" '+ BtnStyle+'>'+SvgFirst+'</a>';
  Result:= Result+ '<a id="scrollprior_' +Name + '" '+ BtnStyle+'>'+SvgPrior+'</a>';
  Result:= Result+ '<a id="scrollpriorpg_' +Name + '" '+pgpriorsize+'>'+PictureCursorBack+'</a>';
  Result:= Result+ '<a id="scrollnextpg_' +Name + '" '+pgnextsize+'>'+PictureCursorBack+'</a>';
  Result:= Result+ '<a id="scrollcursor_' +Name +'" '+ CursorStyle+'>'+PictureCursor+'</a>';
  Result:= Result+ '<a id="scrollnext_' +Name + '" '+ BtnStyle+'>'+ SvgNext+'</a>';
  Result:= Result+ '<a id="scrolllast_' +Name +'" '+ BtnStyle+'>'+ SvgLast+'</a>';
  Result:= Result+ '</div>';
  Result:= Result+ '<input type="hidden" id="idscrollval_'+Name+'" name="'+Name+'" value="'+Text + '">';
end;

function TYScrollbar.Yscript: string;
var
  myCtrl : TWinControl;
  sTmp : string;
function functionscroll(name,fncname : string) : string;
begin
  result := 'function '+fncname+'_' + Name+'_click() {';
  sTmp := 'RefreshMe("'+fncname+'_'+name+'");';
  if  Assigned(fTargetView) then
  begin
    myCtrl :=  fTargetView;
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
var sTaille,sPosition,sGrandeur : string;

begin

  result := 'var dragging' + Name+' = false;';
  result := result +'var maxValue' + Name+' = '+IntToStr(fMaxValue)+';';
  result := result +'var pageSizePercent' + Name+' = '+IntToStr(fPageSizePercent)+';';
  result := result +'var postouch' + Name+' = 0;';
  result := result +'function scrollcursor_' + Name+'_dragstart(e) {';
  result := result +'e.preventDefault();';
  result := result +'dragging' + Name+' = true;';
  result := result +'}';

  result := result +'function scrollcursor_' + Name+'_dragmove(e) {';
  if fVertical = true then
    result := result +'scrollcursor_' + Name+'_dodragmove(e.pageY);'
  else
    result := result +'scrollcursor_' + Name+'_dodragmove(e.pageX);' ;
  result := result +'}';

  result := result +'function scrollcursor_' + Name+'_touchmove(e) {';
  if fVertical = true then
     result := result +'scrollcursor_' + Name+'_dodragmove(e.touches[0].clientY);'
  else
      result := result +'scrollcursor_' + Name+'_dodragmove(e.touches[0].clientX);';
  result := result +'}';

  result := result +'function scrollcursor_' + Name+'_dodragmove(delta) {';
  result := result +'if (dragging' + Name+'){';
  result := result +'  var elem = document.getElementById("id'+Name+'");';
  if fVertical = true then
  begin
    sTaille := 'width'; sPosition := 'top'; sGrandeur := 'height';
    result := result + 'var decal = -window.pageYOffset;';
  end
  else
  begin
    sTaille := 'height'; sPosition := 'left'; sGrandeur := 'width';
    result := result + 'var decal = -window.pageXOffset;';//+elem.offsetParent.getBoundingClientRect().top;';
  end;
  result := result + 'var poscur = delta-elem.getBoundingClientRect().'+sPosition+';';
  result := result + 'var taille = elem.getBoundingClientRect().'+sTaille+';';
  result := result + 'var grand = elem.getBoundingClientRect().'+sGrandeur+';';

{  result := result + 'document.getElementById("scrollpriorpg_'+Name+'").style.'+sTaille+' = taille+ "px";';
  result := result + 'document.getElementById("scrollnextpg_'+Name+'").style.'+sTaille+' = taille+ "px";';
  result := result + 'document.getElementById("scrollfirst_'+Name+'").style.'+sTaille+' = taille+ "px";';
  result := result + 'document.getElementById("scrolllast_'+Name+'").style.'+sTaille+' = taille+ "px";';
  result := result + 'document.getElementById("scrollprior_'+Name+'").style.'+sTaille+' = taille+ "px";';
  result := result + 'document.getElementById("scrollnext_'+Name+'").style.'+sTaille+' = taille+ "px";';
  result := result + 'document.getElementById("scrollcursor_'+Name+'").style.'+sTaille+' = taillecur+ "px";';
                            }

  result := result + 'if (taille*5>grand) {taille = Math.round(grand/7);}';
  result := result + 'var zonescroll = grand-(4*taille);';
  result := result + 'var taillecur = zonescroll*pageSizePercent' + Name+'/100;';
//  result := result + 'if (taillecur==0) {taillecur=taille;}';
  result := result + 'if (taillecur<taille) {taillecur=taille;}';
  result := result + 'poscur = Math.round(poscur-(2*taille)-(taillecur/2));' ;
  result := result + 'if (decal+poscur<0) {poscur= -decal;}';
  result := result + 'if (decal+poscur>(zonescroll-(taillecur))) {poscur=(zonescroll-(decal+taillecur));}';

  result := result + 'document.getElementById("scrollpriorpg_'+Name+'").style.'+sGrandeur+' = String(decal+poscur) + "px";';
  result := result + 'document.getElementById("scrollnextpg_'+Name+'").style.'+sPosition+' = String(decal+(2*taille)+poscur+taillecur)+ "px";';
  result := result + 'document.getElementById("scrollnextpg_'+Name+'").style.'+sGrandeur+' = String(zonescroll-(decal+poscur+taillecur)) + "px";';
  result := result + 'document.getElementById("scrollcursor_'+Name+'").style.'+sPosition+' = String(decal+(2*taille)+poscur) + "px";';


{  result := result + 'document.getElementById("scrollnext_'+Name+'").style.'+sPosition+' = String(decal+taille)+ "px";';
  result := result + 'document.getElementById("scrolllast_'+Name+'").style.'+sPosition+' = String(decal+grand-(taille))+ "px";';
  result := result + 'document.getElementById("scrollprior_'+Name+'").style.'+sPosition+' = String(decal+grand-(2*taille))+ "px";';

  result := result + 'document.getElementById("scrollpriorpg_'+Name+'").style.'+sGrandeur+' = taille+ "px";';
  result := result + 'document.getElementById("scrollnextpg_'+Name+'").style.'+sGrandeur+' = taille+ "px";';
  result := result + 'document.getElementById("scrollfirst_'+Name+'").style.'+sGrandeur+' = taille+ "px";';
  result := result + 'document.getElementById("scrolllast_'+Name+'").style.'+sGrandeur+' = taille+ "px";';
  result := result + 'document.getElementById("scrollprior_'+Name+'").style.'+sGrandeur+' = taille+ "px";';
  result := result + 'document.getElementById("scrollnext_'+Name+'").style.'+sGrandeur+' = taille+ "px";';
  result := result + 'document.getElementById("scrollcursor_'+Name+'").style.'+sGrandeur+' = taillecur+ "px";';
    }

  result := result +'var percentage = (decal+poscur) * maxValue' + Name+';';
  result := result +'if (zonescroll==taillecur) {percentage = 0' +
                    ';} else {percentage = Math.round(percentage/(zonescroll-taillecur));}';
  result := result +'document.getElementById("idscrollval_' + Name + '").value = percentage;';
  result := result +'}}';
  result := result +'function scrollcursor_' + Name+'_dragend() {';
  result := result +'if (dragging' + Name+') {';
  if  Assigned(fTargetView) then
  begin
    sTmp := 'RefreshMe("scrollcursor_'+name+':"+document.getElementById("idscrollval_' + Name + '").value);';
    result := result +'dragging' + Name+' = false;';
    myCtrl :=  fTargetView;
    while not (myCtrl is TForm) do
    begin
       if myCtrl is TYCustomView  then
       begin
          sTmp:= 'document.getElementById("id'+myCtrl.Name+'").contentWindow.'+sTmp;
       end;
       myCtrl := myCtrl.Parent;
    end;
    result := result +JVS_ParentForm+sTmp;
  end
  else result := result +'RefreshMe("scrollcursor_'+name+'");';
  result := result + '}}' ;
  result := result + functionscroll(name,'scrollfirst');
  result := result + functionscroll(name,'scrolllast');
  result := result + functionscroll(name,'scrollprior');
  result := result + functionscroll(name,'scrollnext');
  result := result + functionscroll(name,'scrollnextpg');
  result := result + functionscroll(name,'scrollpriorpg');
  result := result +'if (window.addEventListener) {';
  result := result +'document.getElementById("scrollcursor_'+ Name + '").addEventListener("mousedown", function(e) {scrollcursor_'+ Name+'_dragstart(e);});';
  result := result +'document.getElementById("scrollcursor_'+ Name + '").addEventListener("touchstart", function(e) {scrollcursor_'+ Name+'_dragstart(e);});';
  result := result +'document.getElementById("scrolllast_'+Name+'").addEventListener("click", function(e) { scrolllast_'+Name+'_click(e);});';
  result := result +'document.getElementById("scrollfirst_'+Name+'").addEventListener("click", function(e) { scrollfirst_'+Name+'_click(e);});';
  result := result +'document.getElementById("scrollprior_'+Name+'").addEventListener("click", function(e) { scrollprior_'+Name+'_click(e);});';
  result := result +'document.getElementById("scrollnext_'+Name+'").addEventListener("click", function(e) { scrollnext_'+Name+'_click(e);});';
  result := result +'document.getElementById("scrollpriorpg_'+Name+'").addEventListener("click", function(e) { scrollpriorpg_'+Name+'_click(e);});';
  result := result +'document.getElementById("scrollnextpg_'+Name+'").addEventListener("click", function(e) { scrollnextpg_'+Name+'_click(e);});';
  result := result +'}';
end;

function TYScrollbar.YScript_browserResize: string;
var sTaille,sPosition,sGrandeur : string;
begin
//    result:= 'console.log("resize ('+Name+')");';
  result:= '';
  result := result+'var elem = document.getElementById("id'+Name+'");';
  result := result + 'var value = document.getElementById("idscrollval_'+Name+'").value;';
  if fVertical = true then
  begin
    sTaille := 'width'; sPosition := 'top'; sGrandeur := 'height';
  end
  else
  begin
    sTaille := 'height'; sPosition := 'left'; sGrandeur := 'width';
  end;
  result := result + 'var taille = elem.getBoundingClientRect().'+sTaille+';';
  result := result + 'document.getElementById("scrollfirst_'+Name+'").style.'+sTaille+' = String(taille) + "px";';
  result := result + 'document.getElementById("scrollprior_'+Name+'").style.'+sTaille+' = String(taille )+ "px";';
  result := result + 'document.getElementById("scrollpriorpg_'+Name+'").style.'+sTaille+' = String(taille) + "px";';
  result := result + 'document.getElementById("scrollnextpg_'+Name+'").style.'+sTaille+' = String(taille) + "px";';
  result := result + 'document.getElementById("scrollnext_'+Name+'").style.'+sTaille+' = String(taille) + "px";';
  result := result + 'document.getElementById("scrolllast_'+Name+'").style.'+sTaille+' = String(taille) + "px";';
  result := result + 'document.getElementById("scrollcursor_'+Name+'").style.'+sTaille+' = String(taille) + "px";';

  result := result + 'var grand = elem.getBoundingClientRect().'+sGrandeur+';';
  result := result + 'if (taille*5>grand) {taille = Math.round(grand/7);}';
  result := result + 'var zonescroll = grand-4*taille;';
  result := result + 'var taillecur = zonescroll*pageSizePercent' + Name+'/100;';
//  result := result + 'if (taillecur==0) {taillecur=taille;}';
//  result := result + 'if (taillecur<14) {taillecur=14;}';
  result := result + 'if (taillecur<taille) {taillecur=taille;}';
  result := result + 'var poscur =0;if (maxValue' + Name+' !=0){poscur = ((zonescroll-taillecur)*value/maxValue' + Name+')};';


  result := result + 'document.getElementById("scrollfirst_'+Name+'").style.'+sPosition+' = 0+"px";';
  result := result + 'document.getElementById("scrollfirst_'+Name+'").style.'+sGrandeur+' = String(taille) + "px";';

  result := result + 'document.getElementById("scrollprior_'+Name+'").style.'+sPosition+' = String(taille) + "px";';
  result := result + 'document.getElementById("scrollprior_'+Name+'").style.'+sGrandeur+' = String(taille) + "px";';

  result := result + 'document.getElementById("scrollpriorpg_'+Name+'").style.'+sPosition+' = String(taille*2) + "px";';
  result := result + 'document.getElementById("scrollpriorpg_'+Name+'").style.'+sGrandeur+' = String(poscur) + "px";';

  result := result + 'document.getElementById("scrollnextpg_'+Name+'").style.'+sPosition+' = String(2*taille+taillecur+poscur)+ "px";';
  result := result + 'document.getElementById("scrollnextpg_'+Name+'").style.'+sGrandeur+' = String(zonescroll-poscur-taillecur) + "px";';

  result := result + 'document.getElementById("scrollnext_'+Name+'").style.'+sPosition+' = String(grand-(2*taille)) + "px";';
  result := result + 'document.getElementById("scrollnext_'+Name+'").style.'+sGrandeur+' = String(taille) + "px";';

  result := result + 'document.getElementById("scrolllast_'+Name+'").style.'+sPosition+' = String(grand-taille) + "px";';
  result := result + 'document.getElementById("scrolllast_'+Name+'").style.'+sGrandeur+' = String(taille) + "px";';

  result := result + 'document.getElementById("scrollcursor_'+Name+'").style.'+sPosition+' = String((2*taille)+poscur) + "px";';
  result := result + 'document.getElementById("scrollcursor_'+Name+'").style.'+sGrandeur+' = String(taillecur) + "px";';
end;

function TYScrollbar.Yscript_mousemove: string;
begin
  Result:='scrollcursor_'+Name+'_dragmove(e);';
end;

function TYScrollbar.Yscript_touchmove: string;
begin
  Result:='scrollcursor_'+Name+'_touchmove(e);';
end;

function TYScrollbar.Yscript_mouseup: string;
begin
  Result:='scrollcursor_'+Name+'_dragend();';
end;

function TYScrollbar.Yscript_touchend: string;
begin
  Result:='scrollcursor_'+Name+'_dragend();';
end;

procedure TYScrollbar.FillFromRequest(ARequestContent: TStrings;
  var vOnClick: TYHtmlEvent;var Sender:TObject; YHTMLEXIT: string;var ErrorMessage : string);
var stmp : string;
begin
  inherited FillFromRequest(ARequestContent, vOnClick,Sender, YHTMLEXIT,ErrorMessage);
  if (YHTMLEXIT = 'scrollfirst_'+name) then if Assigned(fOnClickFirst) then
  begin
    vOnClick := TYHtmlEvent(fOnClickFirst);
    Sender := self;
  end;
  if (YHTMLEXIT = 'scrolllast_'+name) then if Assigned(fOnClickLast) then
  begin
    vOnClick := TYHtmlEvent(fOnClickLast);
    Sender := self;
  end;
  if (YHTMLEXIT = 'scrollprior_'+name) then if Assigned(fOnClickPrior) then
  begin
    vOnClick := TYHtmlEvent(fOnClickPrior);
    Sender := self;
  end;
  if (YHTMLEXIT = 'scrollnext_'+name) then if Assigned(fOnClickNext) then
  begin
    vOnClick := TYHtmlEvent(fOnClickNext);
    Sender := self;
  end;
  if (YHTMLEXIT = 'scrollpriorpg_'+name) then if Assigned(fOnClickPriorPG) then
  begin
    vOnClick := TYHtmlEvent(fOnClickPriorPG);
    Sender := self;
  end;
  if (YHTMLEXIT = 'scrollnextpg_'+name) then if Assigned(fOnClickNextPG) then
  begin
    vOnClick := TYHtmlEvent(fOnClickNextPG);
    Sender := self;
  end;
  if (YHTMLEXIT = 'scrollcursor_'+name) then if Assigned(fOnClickNextPG) then
  begin
    vOnClick := TYHtmlEvent(fOnClickScroll);
    Sender := self;
  end;

  stmp := StrToken(YHTMLEXIT,':');
  if stmp = ('scrollcursor_scrollbar_'+name) then
  begin
    Text := YHTMLEXIT;
    vOnClick := TYHtmlEvent(fOnClickScroll);
    Sender := self;
  end;

end;

end.
