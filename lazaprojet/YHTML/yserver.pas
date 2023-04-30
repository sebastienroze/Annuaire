unit YServer;

{$mode objfpc}{$H+}

interface

uses
  fphttpserver,syncobjs, HTTPDefs,YView,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;


const CsFileLocation = 'files\' ;

type

  TYServerThread = class;

  TYFormRequest = Procedure (Sender : TObject; var aNewForm : TForm;{%H-}FormName : string) of object;
  TYActivityMonitor = Procedure (Sender : TObject;{%H-}UserName: string;{%H-}isFile : boolean;{%H-}isDone : boolean) of object;

  { TYServer }

  TYServer = class(TComponent)
  private
    function GetActive: Boolean;
    procedure SetActive(AValue: Boolean);
  protected
    factive : boolean;
    LeYServerThread : TYServerThread;
    FOnFormRequest : TYFormRequest;
    FOnActivityMonitor :TYActivityMonitor;
    LConnections : TStringList;
    lTemporaryURL : TStringList;
    lCacheFiles: TStringList;
    function GetCacheFile(Filename : string) : TMemoryStream;
  public
    YFileLocationPath : string;
    constructor Create(AOwner: TComponent); override;
    function GetConnectionCount : integer;
    function GetModuloConnectionTotal : string;
    function UpdateModuloConnectionTotal : string;
    function NewConnection(UserId : string; WelcomeForm : TForm) : String;
    procedure RemoveConnection(UserId : string);
    function UpdateConnectID(YHTMLID,aUserName : string ) : string;
    procedure UpdateFormYHTMLID(myForm : Tform);
    procedure StoreForm(myForm : Tform );
    function GetConnection(ARequest: TRequest;var YHTMLID : string) : TForm;
    function GetConnectionForm(ConnectionIndex:integer) : TForm;
    function GetConnectionUser(ConnectionIndex:integer) : string;
    function FindConnection(UserId: string) : TForm;
    procedure SendFile(filename : string;AResponse: TResponse);
//    procedure AddTemopraryURL(Urlname : string;filename : string);
//    procedure RemoveTemopraryURL(Urlname : string);
    procedure RemoveCachedFile(Filename : string) ;
//    function FindYView(ARequest: TRequest) : TYView;
  published
    destructor destroy;override;
    Property Active : Boolean Read GetActive Write SetActive Default false;
    Property OnFormRequest : TYFormRequest Read FOnFormRequest Write FOnFormRequest;
    Property OnActivityMonitor : TYActivityMonitor Read FOnActivityMonitor Write FOnActivityMonitor;
  end;

  { TYServerThread }

  TYServerThread = class(TThread)
  private
    _Error: string;
  public
    LeHTTPServer: TFPHttpServer;
    LeYServer  : TYServer;
    procedure LeFPHttpServerRequest(Sender: TObject;
      var ARequest: TFPHTTPConnectionRequest;
      var AResponse: TFPHTTPConnectionResponse);
    constructor Create(owner : TComponent );
    destructor Destroy; override;
    procedure Execute; override;
    property Error: string read _Error;
    function YMessageInfo(AMessage : string;aYHTMLID : string) : TForm;
  end;


procedure Register;
function ExctractConnectID(YHTMLID : string ) : string;
function GenereHtml(Composant : TWinControl) : string;

implementation

uses YHtmlControl,YHtmlDocument,strprocs,YButton,YText,YClass,YDbGrid,strutils;


var
      MyCriticalSection : syncobjs.TCriticalSection ;
      ConnectionTotal : integer;
      MainServerKey : string;


procedure Register;
begin
  {$I yserver_icon.lrs}
  RegisterComponents('YHTML',[TYServer]);
end;

{ connections}

procedure GenerateMainServerKey;
var i : integer;
begin
  Randomize;
  MainServerKey:= '';
  for i := 0 to 128 do MainServerKey:= MainServerKey + chr(48+Random(78));
end;

function Encrypte(YHTMLID : string ) : string;
var i : integer;
    ServerKey : string;
    ch : string;
    valch : integer;
    valserv : integer;

begin
  ServerKey := MainServerKey;
  result := '';
  for i := 1 to Length(YHTMLID) do
  begin
     ch := Copy(YHTMLID,i,1);
     valch :=  Ord(ch[1]);
     valserv :=  Ord(ServerKey[i]);
     valch := valch + valserv;
     valserv := (valch mod 26);
     valch:= (valch - valserv) div 26;
     valch := valch+65;
     valserv := valserv+65;
     result := result+chr(valch)+chr(valserv);
  end;

end;

function Decrypte(YHTMLID : string ) : string;
var i : integer;
    ServerKey : string;
    ch : string;
    valch : integer;
    valserv : integer;
begin
  ServerKey := MainServerKey;
  result := '';
  for i := 1 to (Length(YHTMLID) div 2) do
  begin
      ch := Copy(YHTMLID,(i*2)-1,1);
      valch := Ord(ch[1]);
      ch := Copy(YHTMLID,(i*2),1);
      valserv := Ord(ch[1]);
      valch := valch-65;
      valserv := valserv-65;
      valch := (valch*26) +valserv;
      valserv :=  Ord(ServerKey[i]);
      valch := valch-valserv;
      result := result+chr(valch);
  end;

end;

function ExctractConnectID(YHTMLID : string ) : string;
begin
//   YHTMLID :=Decrype(YHTMLID);
   if Copy(YHTMLID,1,1) = '_' then
     result := ''
   else    if Copy(YHTMLID,1,1) = '-' then
     result  := Copy(YHTMLID,6,255)
   else
     result  := Copy(YHTMLID,5,255);
end;


procedure FillFormRec(cpn : TComponent; ARequest : TRequest; var vOnClick : TYHtmlEvent;var aSender : TObject; var HtmlDoc : TYHtmlDocument;YHTMLEXIT : string;var ErrorMessage : string);
var
  LeCpn : TComponent ;
  i : integer;
begin
  for i := 0 to cpn.ComponentCount  -1 do
  begin
    LeCpn :=  Cpn.Components[i];
    if not (LeCpn is TForm) then
       FillFormRec(LeCpn,ARequest,vOnClick,aSender,HtmlDoc,YHTMLEXIT, ErrorMessage);
    if (LeCpn is TYHtmlDocument) then
    begin
      HtmlDoc := TYHtmlDocument(LeCpn);
      if ARequest.ContentFields.IndexOfName('YHTMLFOCUS') >= 0 then HtmlDoc.CurrentFocus := Copy(ARequest.ContentFields.Values['YHTMLFOCUS'],3,255);
    end
    else if LeCpn is TYHtmlControl then TYHtmlControl(LeCpn).FillFromRequest(ARequest.ContentFields,vOnClick,aSender,YHTMLEXIT,ErrorMessage)
    else if LeCpn is TYHtmlComponent then TYHtmlComponent(LeCpn).FillFromRequest(ARequest.ContentFields,vOnClick,aSender,YHTMLEXIT);
  end;
end;

function FillForm(myForm:TControl; ARequest: TRequest;var ErrorMessage : string) : TYHtmlDocument;
var
  HtmlDoc : TYHtmlDocument;
  vOnClick : TYHtmlEvent;
  YHTMLEXIT : string;
  aSender : TObject;
begin
  vOnClick := nil;aSender := nil;
  HtmlDoc := nil;
  ErrorMessage := '';
  if Assigned(ARequest) and Assigned(myForm) then
  begin
    if (myForm.Enabled = true) then
    begin
      YHTMLEXIT :=  ARequest.ContentFields.Values['YHTMLEXIT'];
      FillFormRec(myForm,ARequest,vOnClick,aSender,HtmlDoc,YHTMLEXIT,ErrorMessage);
      myForm.Enabled:= false;
      try
        if Assigned(vOnClick) then vOnClick(aSender);
      except
        on E : Exception do
            begin
              ErrorMessage := ErrorMessage+E.ClassName + ' signale :<br>'+E.Message+ '<br>';
            end;
      end;
      myForm.Enabled:= true;
    end;
  end;
  result := HtmlDoc;
end;

function GenereHtml(Composant : TWinControl) : string;
var
  i: integer;
begin
  result := '';
  if Composant is TYDbGrid then
  begin
    TYDbGrid(Composant).AsView := false;
    Result := TYDbGrid(Composant).YHTML;
    TYDbGrid(Composant).AsView := true;
  end
  else
       with  GetYHYMLControls(Composant) do
       try
         for i := 0 to count -1 do
         begin
           if TYHtmlControl(Objects[i]).Generate = true then
             result:= result +TYHtmlControl(Objects[i]).Yhtml;
         end;
       finally
         free;
       end;
end;

procedure GenerateHead(aForm:Tform;aYView : TYHtmlControl;AResponse: TResponse;ErrorMessage : String);
var i : integer;
    myCtrl : TWinControl;
    bIsView : boolean;
    LeYComponent : TYHtmlComponent;
begin
  bIsView := Assigned(aYView);
  with AResponse.Contents do
  begin
  Add('<head>');
  Add('<title>'+aForm.Caption+'</title>');
  Add('<link rel="icon" href="/favicon.ico" type="image/x-icon">');
  Add('<meta name="viewport" content="width=device-width, initial-scale=1">');//Responsive Web Design - The Viewport
  Add('<meta http-equiv="cache-control" content="no-cache" />');
  Add('<meta charset="UTF-8">');
  Add('<style>');
  if aYView is TYDbGrid then Add('body{margin: 0;}');
  for i := 0 to aForm.ComponentCount  -1 do
  begin
    if (aForm.Components[i] is TYHtmlControl) then
    begin
       if (TYHtmlControl(aForm.Components[i]).Generate = true) then
       begin
         myCtrl := TYHtmlControl(aForm.Components[i]).FindViewParent;
         if ((aForm = myCtrl) and (bIsView = false)) or ((bIsView = True) and (aYView = myCtrl)) then
         begin
             TYHtmlControl(aForm.Components[i]).AddCss(AResponse.Contents);
         end;
         if aForm.Components[i] is TYDbGrid then
         begin
           TYDbGrid(aForm.Components[i]).AsView:= false;
           TYDbGrid(aForm.Components[i]).AddCss(AResponse.Contents);
           TYDbGrid(aForm.Components[i]).AsView:= true;
         end;
       end;
    end;
    if (aForm.Components[i] is TYHtmlComponent) then
    begin
      LeYComponent :=  TYHtmlComponent(aForm.Components[i]);
      if Assigned(LeYComponent.ParentControl) and (LeYComponent.Generate = true) then
      begin
             LeYComponent.ParentControl.InternalScript:=LeYComponent.ParentControl.InternalScript+LeYComponent.YScript;
             LeYComponent.ParentControl.InternalScriptBrowserResize:=LeYComponent.ParentControl.InternalScriptBrowserResize+LeYComponent.Yscript_browserResize;
      end;
    end;
    if (aForm.Components[i] is TYClass) then TYClass(aForm.Components[i]).AddCss(AResponse.Contents);
    if (aForm.Components[i] is TYHtmlDocument) then TYHtmlDocument(aForm.Components[i]).AddCss(AResponse.Contents);
  end;
  if ErrorMessage <> '' then Add('@keyframes blinker {50%{outline-color: #FF0000;}}');
  Add('</style>');
  Add('</head>');
  end;

end;

procedure GenerateForm(aForm:Tform;aYView : TYHtmlControl;ARequest: TRequest;AResponse: TResponse;ErrorMessage : String);
var
    YHTMLIDcr : string;
    shtml : string;
begin
  YHTMLIDcr := Encrypte(aForm.Hint);

  with AResponse.Contents do
  begin
    Add('<form action="' + ARequest.URI + '" onsubmit="return YvalidateForm()" method="POST" autocomplete="off">');
    Add('<input id="idYHTMLID" name="YHTMLID" value="'+YHTMLIDcr+'" style = "display:none;" >');
    Add('<input name="YHTMLEXIT" type="submit" id="idYHTMLEXIT" value="YHTMLEXIT" style = "display:none;">');
    Add('<input name="YHTMLSIZE" type="submit" id="idYHTMLSIZE" value="" style = "display:none;">');
    Add('<input name="YHTMLFOCUS" id="idYHTMLFOCUS" value="" style = "display:none;">');
    {   DEBUG LINES
    Add('<input name="YHTMLID" value="'+YHTMLID+'" style = "position:absolute;" >');
    Add('<p>Values : ');
    Add(  ARequest.ContentFields.Text );
    Add('</p>');
    Add(  ARequest.URI );
    }
    if ErrorMessage <> '' then
    begin
      Add('<div style = "padding: 20px 50px;outline-style: solid; outline-width: 15px;outline-color: black;background-color:black;color: red;animation: blinker 2s linear infinite;">');
//      Add(StrReplace(ErrorMessage,#13#10,'<br>'));
      Add(StringReplace(ErrorMessage,#13#10,'<br>',[rfReplaceAll]));
      add('</div>');
    end;
    if Assigned(aYView) then
    begin
      Add('<input name="YHTMLVIEWNAME" id="idYHTMLVIEWNAME" value="'+aYView.Name+'" style = "display:none;">');
      shtml := GenereHtml(aYView)
    end else
    begin
     shtml := GenereHtml(aForm);
    end;
    Add(shtml);
    Add('</form>');
  end;
end;

procedure AnalysePageScripts(aForm:Tform;aYView : TYHtmlControl;
  var LeScript,LeScriptBrowserResize,LeScriptKeyDown,
          LeScriptMousemove,LeScriptMouseup,LeScriptTouchmove,LeScriptTouchend,CurrentFocus : string;var FocusElt : TYHtmlControl;
          var FocusList,TabOrderList,ControlList,ShortCutList : TStringList;
          var bNoticeBrowserResize,bNoticeKey,bfocusexists : boolean
  );
var i : integer;
   LeYControl : TYHtmlControl;
   LeYComponent: TYHtmlComponent;
   myCtrl : TWinControl;
   myView : TYCustomView;
   MinFocus : string;
   bIsView : Boolean;
   sTmp,sScript,PremierFocus  : string;
   ScriptHp,ScriptHpBrowserResize : string;
begin
  ScriptHp:= ''; ScriptHpBrowserResize := '';
  MinFocus := '';PremierFocus := '';
  bIsView := Assigned(aYView);

  if aYView is TYDbGrid then
  begin
      TYDbGrid(aYView).AsView := false;
      LeScriptBrowserResize :=  TYDbGrid(aYView).YScript_browserResize;
      LeScriptKeyDown :=  TYDbGrid(aYView).Yscript_keydown;
      LeScript := LeScript +TYDbGrid(aYView).YScript;
      TYDbGrid(aYView).AsView := true;
  end;
  for i := 0 to aForm.ComponentCount  -1 do
  begin
       if (aForm.Components[i] is TYHtmlControl) then
       begin
          LeYControl := TYHtmlControl(aForm.Components[i]);
          if LeYControl.Generate = true then
          begin
            bNoticeBrowserResize:= bNoticeBrowserResize or LeYControl.NoticeBrowserResize;
            if LeYControl.FocusEnabled = true then
            begin
              if (LeYControl.TabStop = true) and (not (LeYControl is TYView)) then
              begin
                if  ((PremierFocus = '') or (MinFocus> LeYControl.FullTabOrder)) then
                begin
                   PremierFocus:= LeYControl.YInnerName ;
                   MinFocus:= LeYControl.FullTabOrder;
                   if not Assigned(FocusElt) or (CurrentFocus = '') then FocusElt := LeYControl;
                end;
              end;
              if (CurrentFocus <> '') and (CurrentFocus= LeYControl.YInnerName) then
              begin
                if  (LeYControl is TYView) then CurrentFocus := '' else FocusElt := LeYControl;
              end;
            end;
            myCtrl := LeYControl.FindViewParent;
            if bIsView = False then
            begin
              LeScriptBrowserResize := LeScriptBrowserResize +LeYControl.InternalScriptBrowserResize;
              LeScript := LeScript +  LeYControl.InternalScript;
            end;

            if ((aForm = myCtrl) and (bIsView = false)) or ((bIsView = True) and (aYView = myCtrl)) then
            begin
              if LeYControl.FocusEnabled = true then
              begin
                bfocusexists := true;
                ControlList.AddObject(LeYControl.YInnerName,LeYControl);
                if (LeYControl.TabStop = true) then
                begin
                  TabOrderList.AddObject(LeYControl.FullTabOrder,LeYControl);
                end;
              end;
              sTmp := LeYControl.Yscript_keydown;
              if sTmp<> '' then
                 sTmp := 'if (ycurrentfocus.value == "id'+LeYControl.YInnerName +'") {'+sTmp+'}';
              LeScriptKeyDown := LeScriptKeyDown + sTmp;
              LeScriptBrowserResize := LeScriptBrowserResize + LeYControl.Yscript_browserResize;
              LeScriptMousemove := LeScriptMousemove + LeYControl.Yscript_mousemove;
              LeScriptMouseup := LeScriptMouseup + LeYControl.Yscript_mouseup;
              LeScriptTouchend := LeScriptTouchend + LeYControl.Yscript_touchend;
              LeScriptTouchmove := LeScriptTouchmove + LeYControl.Yscript_touchmove;
              LeScript := LeScript +LeYControl.YScript;

              if (LeYControl.FocusEnabled = true)  then FocusList.AddObject(LeYControl.YInnerName,LeYControl);
              if (LeYControl is TYButton) then
              begin
                if TYButton(LeYControl).ShortcutKeyCode >0 then
                begin
                   ShortCutList.AddObject(StrPad(IntToStr(TYButton(LeYControl).ShortcutKeyCode),'0',3),LeYControl);
                end;
              end;
            end;
            if (bIsView = true) and (LeYControl is TYButton)  then
            begin
              if TYButton(LeYControl).ShortcutKeyCode >0 then bNoticeKey := true;
            end;
          end;
          LeYControl.InternalScript:='';LeYControl.InternalScriptBrowserResize :='';
       end;
       if (aForm.Components[i] is TYHtmlComponent) then
       begin
          LeYComponent := TYHtmlComponent(aForm.Components[i]);
          if (LeYComponent.Generate = true) and (not Assigned(LeYComponent.ParentControl)) then
          begin
            sScript := LeYComponent.YScript_browserResize;
            if (bIsView = false) and (not Assigned(LeYComponent.ParentView)) then
            begin
              case LeYComponent.ScriptsPriority of
                YspNormal :
                begin
                   LeScript := LeScript + LeYComponent.YScript;
                   LeScriptBrowserResize := LeScriptBrowserResize + sScript;
                end;
                YspBeforeNormal :
                begin
                   LeScript := LeYComponent.YScript+LeScript ;
                   LeScriptBrowserResize := sScript+LeScriptBrowserResize ;
                end;
                YspHigh :
                begin
                   ScriptHp := ScriptHp + LeYComponent.YScript;
                   ScriptHpBrowserResize := ScriptHpBrowserResize + sScript;
                end;
                YspBeforeHigh :
                begin
                   ScriptHp := ScriptHp + LeYComponent.YScript;
                   ScriptHpBrowserResize := sScript+ScriptHpBrowserResize ;
                end;
              end;
            end
            else  if (bIsView = True) and (Assigned(LeYComponent.ParentView)) then
            begin
              if (LeYComponent.ParentView = aYView) then
              begin
                sTmp := LeYComponent.YScript;
                if (sTmp<>'') then LeScript := LeScript +(STmp);
//                if (sScript <> '') then bNoticeBrowserResize:= true;
              end;
            end;
          end;
       end;
       if (aForm.Components[i] is TYCustomView) then
       begin
          myView := TYCustomView(aForm.Components[i] );
          if myView is TYDbGrid then
          begin
             if  TYDbGrid(myView).UseYView = false then myView := nil;
          end;
          if Assigned(myView) then
          begin
            if myView.RefreshMe = true then
            begin
              myView.RefreshMe:= false;
              sTmp := 'document.getElementById("id'+myView.Name+'").contentWindow.RefreshMe("")';
              myCtrl :=  myView;
              while not (myCtrl is TForm) do
              begin
                 myCtrl := myCtrl.Parent;
                 if myCtrl is TYView then
                 begin
                    sTmp:= 'document.getElementById("id'+myCtrl.Name+'").contentWindow.'+sTmp;
                 end;
              end;
               LeScript := LeScript +('parent.'+sTmp);
            end;
            if bIsView = false then
            begin
              LeScript := ('var ' + myView.Name + '_loaded = 0;')+LeScript;
            end;
          end;
       end;
  end;
  TabOrderList.Sort;
  LeScriptBrowserResize :=ScriptHpBrowserResize+ LeScriptBrowserResize+'YHTMLCALCSIZE();';
  LeScript:= ScriptHp + LeScript;
  if Assigned(FocusElt) then  CurrentFocus:= FocusElt.YInnerName;
end;

procedure GenerateEvent(AResponse: TResponse;eventname,eventscript : string);
begin
  if eventscript <> '' then
  with AResponse.Contents do
  begin
    Add('function ywin'+eventname+'(e) {');
    Add(eventscript);
    Add('}');
    Add('if (window.addEventListener) {');
    Add('window.addEventListener("'+eventname+'", function(e) {ywin'+eventname+'(e);});');
    Add('}');
  end;
end;

procedure GenerateTabOrderScript(AResponse: TResponse;ControlList,TabOrderList :TStringList;bIsView : Boolean);
var i : integer;
   sfocus : string;
   myCtrl : TWinControl;
   myYCtrl : TYHtmlControl;
   myGrid : TYDbGrid;
   sblur : string;
   binview:boolean;
   sFocusElt : string;
begin
  if ControlList.Count=0 then
  with AResponse.Contents do
  begin
    if bIsView = true then
    begin
      Add('function yfocusNext() {parent.yfocusNext();}');
      Add('function yfocusPrior() {parent.yfocusPrior();}');
      Add('function yfocusFirst() {parent.yfocusNext();}');
      Add('function yfocusLast() {parent.yfocusPrior();}');
    end
    else
    begin
      Add('function yfocusNext() {}');
      Add('function yfocusPrior() {}');
    end;
    Add('function yfocusFirst() {}');
    Add('function yfocusLast() {}');
    Add('function yfocusApply() {}');
    Add('function yblurApply() {}');
  end
  else
  with AResponse.Contents do
  begin
    if TabOrderList.Count=0 then Add('function yfocusFirst(){}function yfocusLast(){}')
    else
    begin
      Add('function yfocusFirst() {ycurrentfocus.value="id'+TYHtmlControl(TabOrderList.Objects[0]).YInnerName+'";');
      if TYHtmlControl(TabOrderList.Objects[0]) is TYView then
      begin
        myYCtrl := TYHtmlControl(TabOrderList.Objects[0]);
        Add( 'if('+myYCtrl.JVS_ParentForm +myYCtrl.Name+'_loaded==1){'+
              'document.getElementById("id'+myYCtrl.Name+'").contentWindow.yfocusFirst();}');
      end;
      Add('}');

      Add('function yfocusLast() {ycurrentfocus.value="id'+TYHtmlControl(TabOrderList.Objects[TabOrderList.Count-1]).YInnerName+'";');
      if TYHtmlControl(TabOrderList.Objects[TabOrderList.Count-1]) is TYView then
      begin
        myYCtrl := TYHtmlControl(TabOrderList.Objects[TabOrderList.Count-1]);
        Add( 'if('+myYCtrl.JVS_ParentForm +myYCtrl.Name+'_loaded==1){'+
              'document.getElementById("id'+myYCtrl.Name+'").contentWindow.yfocusLast();}');
      end;
      Add('}');
      sFocusElt := TYHtmlControl(TabOrderList.Objects[0]).YInnerName;
    end;
    Add('function yfocusNext() {switch (ycurrentfocus.value) {');
    for i := 0 to TabOrderList.Count-1 do
    begin
       if (bIsView = true) and (i =(TabOrderList.Count-1)) then
       begin
         Add('case "id'+TYHtmlControl(TabOrderList.Objects[i]).YInnerName+'":{'+'parent.yfocusNext();break;}');
       end
       else
       begin
         if i <(TabOrderList.Count-1) then myYCtrl:= TYHtmlControl(TabOrderList.Objects[i+1])
         else myYCtrl:= TYHtmlControl(TabOrderList.Objects[0]);
         sfocus := myYCtrl.YInnerName;

         if myYCtrl is TYDbGrid then sblur := 'yblurControls();' else sblur:= '';
         Add('case "id'+TYHtmlControl(TabOrderList.Objects[i]).YInnerName+'":{'+sblur+'ycurrentfocus.value="id'+sfocus+'";');
         if myYCtrl is TYView then
         begin
            Add('if('+myYCtrl.JVS_ParentForm +myYCtrl.Name+'_loaded==1){'
                 +'document.getElementById("id'+myYCtrl.Name+'").contentWindow.yfocusFirst();}');
         end;
         Add('break;}');
       end;
    end;
    if (TabOrderList.Count = 0) and (bIsView = false) then
    begin
      sfocus := '';
      for i := 0 to ControlList.Count-1 do
      begin
         myYCtrl := TYHtmlControl(ControlList.Objects[i]);
         if myYCtrl is TYView then
         begin
           if sfocus <> '' then
           begin
              Add('case "id'+sfocus+'":{ycurrentfocus.value="id'+myYCtrl.Name+'";');
              Add('if('+myYCtrl.JVS_ParentForm +myYCtrl.Name+'_loaded==1){'
              +'document.getElementById("id'+myYCtrl.Name+'").contentWindow.yfocusFirst();};break;}');
           end;
         end;
         sfocus := myYCtrl.Name;
      end;
      if sfocus<> '' then
      begin
         myYCtrl := TYHtmlControl(ControlList.Objects[0]);
         Add('case "id'+sfocus+'":{ycurrentfocus.value="id'+myYCtrl.Name+'";');
         Add('if('+myYCtrl.JVS_ParentForm +myYCtrl.Name+'_loaded==1){'
         +'document.getElementById("id'+myYCtrl.Name+'").contentWindow.yfocusFirst();};break;}');
      end;
    end;
    sblur:= '';
    i := ControlList.IndexOf(sFocusElt);
    if i >0 then if ControlList.Objects[i] is TYDbGrid then sblur := 'yblurControls();';
    Add('default:{'+sblur+'ycurrentfocus.value = "id'+sFocusElt+'";break;}');
    add('}}');
    Add('function yfocusPrior() {switch (ycurrentfocus.value) {');
    for i := 0 to TabOrderList.Count-1 do
    begin
      if (bIsView = true) and (i =0) then
      begin
        Add('case "id'+TYHtmlControl(TabOrderList.Objects[i]).YInnerName+'":{'+'parent.yfocusPrior();break;}');
      end
      else
      begin
         if i >0 then myYCtrl := TYHtmlControl(TabOrderList.Objects[i-1])
         else myYCtrl:= TYHtmlControl(TabOrderList.Objects[TabOrderList.Count-1]);
         sfocus := myYCtrl.YInnerName;
         if myYCtrl is TYDbGrid then sblur := 'yblurControls();' else sblur:= '';
         Add('case "id'+TYHtmlControl(TabOrderList.Objects[i]).YInnerName+'":{'+sblur+'ycurrentfocus.value="id'+sfocus+'";');
         if myYCtrl is TYView then
         begin
            Add('if('+myYCtrl.JVS_ParentForm +myYCtrl.Name+'_loaded==1){'
                 +'document.getElementById("id'+myYCtrl.Name+'").contentWindow.yfocusLast();}');
         end;
         Add('break;}');
      end;
    end;
    if (TabOrderList.Count = 0) and (bIsView = false) then
    begin
       sfocus := '';
       for i := ControlList.Count-1 downto 0 do
       begin
          myYCtrl := TYHtmlControl(ControlList.Objects[i]);
          if myYCtrl is TYView then
          begin
            if sfocus <> '' then
            begin
               Add('case "id'+sfocus+'":{ycurrentfocus.value="id'+myYCtrl.Name+'";');
               Add('if('+myYCtrl.JVS_ParentForm +myYCtrl.Name+'_loaded==1){'
               +'document.getElementById("id'+myYCtrl.Name+'").contentWindow.yfocusLast();};break;}');
            end;
          end;
          sfocus := myYCtrl.Name;
       end;
       if sfocus<> '' then
       begin
          myYCtrl := TYHtmlControl(ControlList.Objects[ControlList.Count-1]);
          Add('case "id'+sfocus+'":{ycurrentfocus.value="id'+myYCtrl.Name+'";');
          Add('if('+myYCtrl.JVS_ParentForm +myYCtrl.Name+'_loaded==1){'
          +'document.getElementById("id'+myYCtrl.Name+'").contentWindow.yfocusLast();};break;}');
       end;
    end;
    sblur:= '';
    i := ControlList.IndexOf(sFocusElt);
    if i >0 then if ControlList.Objects[i] is TYDbGrid then sblur := 'yblurControls();';
    Add('default:{'+sblur+'ycurrentfocus.value = "id'+sFocusElt+'";break;}');
    add('}}');
    Add('function yfocusApply() {switch (ycurrentfocus.value) {');
    for i := 0 to ControlList.Count-1 do
    begin
       binview := false;
       if ControlList.Objects[i] is TYDbGrid then
       begin
         myGrid :=  TYDbGrid(ControlList.Objects[i]);
         sfocus:= 'yfocus_grid'+myGrid.Name+'();';
         if TYHtmlControl(ControlList.Objects[i]).UseFocusKeys = true then
             sfocus := sfocus+'ywantreturnkey=true;'else sfocus := sfocus+'ywantreturnkey=false;';
       end
       else if ControlList.Objects[i] is TYView then
       begin
           myCtrl := TYView(ControlList.Objects[i]);
           binview := true;
           sfocus := 'document.getElementById("id'+myCtrl.Name+'").focus;'
                   + 'document.getElementById("id'+myCtrl.Name+'").contentWindow.yfocusApply();';
       end
       else
       begin
         sfocus := 'var yctrl=document.getElementById("id'+TYHtmlControl(ControlList.Objects[i]).YInnerName +'");' +
                   'yctrl.focus();yctrl.style.outline = "'+CsFocusOutlineStyle+'";';
          if TYHtmlControl(ControlList.Objects[i]).UseFocusKeys = true then
              sfocus := sfocus+'ywantreturnkey=true;'else sfocus := sfocus+'ywantreturnkey=false;';
       end;
       if binview = true then
          sfocus:= 'if('+TYCustomView(myCtrl).JVS_ParentForm +TYCustomView(myCtrl).Name+'_loaded==1){'+sfocus+'}';
       Add('case "id'+TYHtmlControl(ControlList.Objects[i]).YInnerName+'":{'+sfocus+'break;}');
    end;
    add('}}');
    Add('function yblurApply() {switch (ycurrentfocus.value) {');   //console.log("blur '+BoolToStr(binview,'(view)','')+'"+ycurrentfocus.value);
    for i := 0 to ControlList.Count-1 do
    begin
       binview := false;
       if ControlList.Objects[i] is TYDbGrid then
       begin
         myGrid :=  TYDbGrid(ControlList.Objects[i]);
         sfocus:= 'yblur_grid'+myGrid.Name+'();';
         if myGrid.UseYView = true then
         begin
           binview := true;
           sfocus := myGrid.JVS_getElementById+'.contentWindow.'+sfocus;
           myCtrl := myGrid;
{         end
         else
         begin
           myCtrl := myGrid.FindViewParent;
           if myCtrl is TYView then
           begin
              sfocus :=  TYView(myCtrl).JVS_getElementById+'.contentWindow.'+sfocus;
           end;
           }
         end;
       end
       else
       if ControlList.Objects[i] is TYView then
       begin
          myCtrl := TWinControl(ControlList.Objects[i]);
          sfocus := 'document.getElementById("id'+myCtrl.Name +'").contentWindow.yblurApply();';
          sfocus:= 'if('+TYCustomView(myCtrl).JVS_ParentForm +myCtrl.Name+'_loaded==1){'+sfocus+'}';
       end
       else
       begin
          sfocus := 'document.getElementById("id'+TYHtmlControl(ControlList.Objects[i]).YInnerName +'").style.outline = "";';

//          sfocus := TYHtmlControl(ControlList.Objects[i]).JVS_getElementByInnerId+'.style.outline = "";';
//          myCtrl := TYHtmlControl(ControlList.Objects[i]).FindViewParent;
       end;
//       binview := binview or (myCtrl is TYView);
       if binview = true then sfocus:= 'if('+TYCustomView(myCtrl).JVS_ParentForm +TYCustomView(myCtrl).Name+'_loaded==1){'+sfocus+'}';
       Add('case "id'+TYHtmlControl(ControlList.Objects[i]).YInnerName+'":{'+sfocus+'break;}');
    end;
    add('}}');
//    Add('function yblurApply() {yblurApplyStyle();}');


    Add('function yblurControls() {switch (ycurrentfocus.value) {');
    for i := 0 to ControlList.Count-1 do
    begin
       if not (ControlList.Objects[i] is TYCustomView) then
       begin
//         sfocus := TYHtmlControl(ControlList.Objects[i]).JVS_getElementByInnerId+'.blur();';
         sfocus := 'document.getElementById("id'+TYHtmlControl(ControlList.Objects[i]).YInnerName +'").blur();';

//         myCtrl := TYHtmlControl(ControlList.Objects[i]).FindViewParent;
//         if myCtrl is TYCustomView then sfocus:= 'if('+TYCustomView(myCtrl).Name+'_loaded==1){'+sfocus+'}';
         Add('case "id'+TYHtmlControl(ControlList.Objects[i]).YInnerName+'":{'+sfocus+'break;}');
       end;
    end;
    add('}}');
  end;
end;

procedure GenerateKeyEvent(aYView : TYHtmlControl;AResponse: TResponse;LeScriptKeyDown: string;
          TabOrderList,ShortCutList : TStringList;
          bUseFocus : boolean);
var   sTmp : string;
   sParent : string;
   i : integer;
begin
 sTmp := '';sParent := '';
 if  Assigned(aYView) then  sTmp :=aYView.Name;
 if  Assigned(aYView) then  sParent :=aYView.JVS_ParentForm+'parent.';
 with AResponse.Contents do
 begin
  if (bUseFocus = true) then Add('var ycurrentfocus=document.getElementById("idYHTMLFOCUS");var ywantreturnkey=false;');
  if (bUseFocus and (TabOrderList.Count > 0)) or (ShortCutList.Count>0) or (LeScriptKeyDown <> '')
     or (bUseFocus and (not Assigned(aYView))) then
  begin
    Add('function YKeyFocus(event) {event = event || window.event;var key = event.which || event.keyCode;');
//    Add('console.log("YKeyFocus '+sTmp+'");');
    if  LeScriptKeyDown <> '' then Add(LeScriptKeyDown);
    for i := 0 to ShortCutList.Count-1 do
    begin
       sTmp:= ShortCutList.Strings[i];
       Add('if(key == ' + IntToStr(ValInt(sTmp))+ ') {event.preventDefault;'+
         sParent+TYHtmlControl(ShortCutList.Objects[i]).JVS_getElementByInnerId+'.click();return false;}');
    end;
    if (bUseFocus = true) and (TabOrderList.Count > 0) then
    begin
      Add('if ((!(event.shiftKey || event.metaKey || event.altKey || event.ctrlKey)) &&(');
      Add('(((key == 13) || (key == 40)) && ywantreturnkey) ||');
      Add('(key == 9) ))  {');
      Add(sParent+'yblurApply();yfocusNext();'+sParent+'yfocusApply();event.preventDefault;return false;}');
      Add('if(');
      Add('(((!(event.shiftKey || event.metaKey || event.altKey || event.ctrlKey)) &&(key == 38))&&ywantreturnkey) || ');
      Add('((!(event.metaKey || event.altKey || event.ctrlKey))&&(key == 9)&&event.shiftKey )) {');

      Add(sParent+'yblurApply();yfocusPrior();'+sParent+'yfocusApply();event.preventDefault;return false;}');
    end;
    if Assigned(aYView) then Add(sParent+'ywantreturnkey=ywantreturnkey;return '+sParent+'YKeyFocus(event);')
    else
    begin
      Add('if (((key>=112)&&(key<=121)) ||(key==123)) {event.preventDefault;return false;}');
      Add('if (key==-1) {event.preventDefault;return false;}');
      Add('return true;');
    end;
    Add('}document.onkeydown = YKeyFocus;');
  end;
 end;
end;

procedure GenerateFocusScript(AResponse: TResponse;aYView : TYHtmlControl;
          FocusElt : TYHtmlControl;FocusList : TStringList);
var
   i : integer;
   sParent,seltViewParent : string;
   eltViewParent : TControl;
   sView : string;
begin
  with AResponse.Contents do
  begin
   for i := 0 to FocusList.Count-1 do
   begin
      if not(FocusList.Objects[i] is TYCustomView) then
      begin
        sParent := TYHtmlControl(FocusList.Objects[i]).JVS_ParentForm;
        Add('document.getElementById("id'+TYHtmlControl(FocusList.Objects[i]).YInnerName+
            '").addEventListener("focus", function(e) {');
        Add(sParent+'yblurApply();');
        Add('var bytest=(ycurrentfocus.value=="idHTMLEXIT");');
        Add('ycurrentfocus.value="id'+TYHtmlControl(FocusList.Objects[i]).YInnerName+'";');
        Add('if (bytest){RefreshMe("");}');
        eltViewParent := aYView;
        seltViewParent := '';
        while eltViewParent is TYCustomView do
        begin
            seltViewParent :=seltViewParent+ 'parent.';
            Add(seltViewParent+'ycurrentfocus.value="id'+eltViewParent.Name+'";');
            eltViewParent := TYCustomView(eltViewParent).FindViewParent;
        end;
        Add('document.getElementById("id'+TYHtmlControl(FocusList.Objects[i]).YInnerName+'").style.outline = "'+CsFocusOutlineStyle+'";');
        Add('ywantreturnkey=' + BoolToStr(TYHtmlControl(FocusList.Objects[i]).UseFocusKeys,'true','false') + ';');
        Add('return true;})');
      end
   end;
   sParent := '';
   if Assigned(aYView) then sParent := aYView.JVS_ParentForm+'parent.';
   if Assigned(FocusElt) then
   begin
      Add(sParent+'yblurApply();');
      eltViewParent := FocusElt.FindViewParent;
      seltViewParent := '';
      if eltViewParent is TYView then
      begin
        seltViewParent := 'if ('+sParent+TYView(eltViewParent).YInnerName+'_loaded==1)';
        sView := TYView(eltViewParent).JVS_getElementById + '.contentWindow.'
      end
      else sView := '';
      Add(seltViewParent+'{'+sParent+sView+'ycurrentfocus.value = "id'+FocusElt.YInnerName+'";}') ;
      while (eltViewParent is TYView) do
      begin
         sView := 'ycurrentfocus.value = "id'+TYView(eltViewParent).YInnerName+'";';
         eltViewParent := TYView(eltViewParent).FindViewParent;
         seltViewParent := '';
         if (eltViewParent is TYView) then
         begin
            seltViewParent := 'if ('+sParent+TYView(eltViewParent).YInnerName+'_loaded==1)';
            sView := TYView(eltViewParent).JVS_getElementById + '.contentWindow.'+sView;
         end;
         Add(seltViewParent+'{'+sParent+sView+'}') ;
      end;
      Add(sParent+'yfocusApply();');
   end;
 end;
end;

procedure GenerateScript(aForm:Tform;aYView : TYHtmlControl; HtmlDoc : TYHtmlDocument;ARequest: TRequest;AResponse: TResponse);
var
  LeScriptBrowserResize : string;
  LeScript,LeScriptKeyDown,LeScriptMousemove,LeScriptTouchmove,LeScriptMouseup,LeScriptTouchend : string;
  sTmp : string;
  bIsView,bNoticeBrowserResize,bNoticeKey,bfocusexists,bUseYFocus : boolean;

  CurrentFocus : string;
  FocusElt : TYHtmlControl;
  FocusList: TStringList;
  TabOrderList: TStringList;
  ShortCutList: TStringList;
  ControlList : TStringList;

begin
 with AResponse.Contents do
 begin
  bUseYFocus := false;
  if Assigned(HtmlDoc) then bUseYFocus := HtmlDoc.UseYFocus;
  Add('<script>');
  if (Assigned(aYView)) and (bUseYFocus = true) then
     Add('function YvalidateForm() {document.getElementById("idYHTMLFOCUS").value = '+aYView.JVS_ParentForm+'ycurrentfocus.value;return true;}')
  else
     Add('function YvalidateForm() {return true;}');
  Add('function YHTMLCALCSIZE(){document.getElementById("idYHTMLSIZE").value =window.innerWidth +"/"+window.innerHeight;}YHTMLCALCSIZE();');
  bIsView := Assigned(aYView);
  if bIsView = true then Add(aYView.JVS_ParentForm+'parent.'+aYView.Name + '_loaded = 1;' );
  if Assigned(aYView) and (aYView is TYView) then
  begin
    Add('document.getElementById("idYHTMLID").value = parent.document.getElementById("idYHTMLID").value;');
    if (TYView(aYView).RefreshParent = true) then
    begin
        TYView(aYView).RefreshParent := false;
        Add('parent.RefreshMe("");');
    end ;
  end;

  FocusElt := nil;CurrentFocus := '';
  FocusList := TStringList.Create;TabOrderList  := TStringList.Create;
  ShortCutList :=TStringList.Create; ControlList:=TStringList.Create;
  bNoticeBrowserResize := false;bNoticeKey := false;bfocusexists := false;

  LeScript := '';
  LeScriptBrowserResize := '';LeScriptMouseup:='';LeScriptTouchmove:= '';
  LeScriptTouchend:= '';LeScriptMousemove:= '';LeScriptKeyDown:= '';

  if Assigned(HtmlDoc) then
  begin
    if HtmlDoc.CurrentFocus<> '' then CurrentFocus :=HtmlDoc.CurrentFocus ;
  end;

  AnalysePageScripts(aForm,aYView,
    LeScript,LeScriptBrowserResize,LeScriptKeyDown,LeScriptMousemove,LeScriptMouseup,LeScriptTouchmove,LeScriptTouchend,
    CurrentFocus,FocusElt,FocusList,TabOrderList,ControlList,ShortCutList,bNoticeBrowserResize,bNoticeKey,bfocusexists);



  if Assigned(HtmlDoc) then
  begin
    if HtmlDoc.CurrentFocus= '' then HtmlDoc.CurrentFocus := CurrentFocus;
  end;

  if (CurrentFocus <> '') then bNoticeKey:= true;

  if {(bIsView = false) and }(bUseYFocus = true) then GenerateTabOrderScript(AResponse,ControlList,TabOrderList,bIsView);


  Add(LeScript);

  if Assigned(aYView) then sTmp:= 'parent.'+aYView.JVS_ParentForm+aYView.Name + '_loaded = 0;'
  else sTmp:= '';
  if (aYView is TYDbGrid) then
  begin
    bNoticeBrowserResize:= true;
    bNoticeKey := true;
  end ;

  Add('var ygettingrefreshed = false;');
  Add('function RefreshMe(exitcode) {if(ygettingrefreshed == false){ygettingrefreshed = true;YHTMLCALCSIZE();');
  if bIsView = true then Add('if (exitcode == "!") {parent.RefreshMe("!");exit;};');
  Add('var  myExit = document.getElementById("idYHTMLEXIT");myExit.value = exitcode;'+sTmp+'myExit.click();}}');

  LeScriptBrowserResize := 'console.log("Resize'+BoolToStr(bIsView,'(view)','')+'");'+ LeScriptBrowserResize;

  GenerateEvent(AResponse,'mousemove',LeScriptMousemove);
  GenerateEvent(AResponse,'mouseup',LeScriptMouseup);
  GenerateEvent(AResponse,'touchend',LeScriptTouchend);
  GenerateEvent(AResponse,'resize',LeScriptBrowserResize);
  GenerateEvent(AResponse,'touchmove',LeScriptTouchmove);
  if LeScriptBrowserResize <> '' then Add('ywinresize();');

  GenerateKeyEvent(aYView,AResponse,LeScriptKeyDown,
           TabOrderList,ShortCutList,bUseYFocus );

  if (bUseYFocus = true) then  GenerateFocusScript(AResponse,aYView,FocusElt,FocusList);

  if (bNoticeBrowserResize = true) then
  begin
    if Assigned(aYView) then
    begin
       Add(aYView.JVS_ParentForm+'parent.ywinresize();');
       Add('ywinresize();'); // double appel pour chrome
    end;
  end;
  if Assigned(HtmlDoc) then
  begin
    LeScript:= HtmlDoc.Yscript;
    if LeScript<> '' then Add(LeScript);
    if (HtmlDoc.AllowNavigateBack = false) then
    Add('window.history.forward();');
  end
  else Add('window.history.forward();');
  Add('</script>');
 end;
 TabOrderList.Free;ShortCutList.Free;FocusList.Free;
 if bIsView = true then
 begin
//    if Assigned(aYView) and (ARequest.ContentFields.IndexOfName('YHTMLSIZE') >=0) then aYView.YWindowSize := ARequest.ContentFields.Values['YHTMLSIZE'];
 end
 else
 begin
    if Assigned(HtmlDoc) and (ARequest.ContentFields.IndexOfName('YHTMLSIZE') >=0) then HtmlDoc.YWindowSize := ARequest.ContentFields.Values['YHTMLSIZE'];
 end;
 if aYView is TYDbGrid then TYDbGrid(aYView).AsView := true;

end;

procedure GeneratePage(aForm:Tform;aYView : TYHtmlControl; HtmlDoc : TYHtmlDocument;ARequest: TRequest;AResponse: TResponse;ErrorMessage : String);
begin
  with AResponse.Contents do
  begin
     Add('<!DOCTYPE html>');
     Add('<html>');
     GenerateHead(aForm,aYView,AResponse,ErrorMessage);
     if Assigned(HtmlDoc ) then Add(HtmlDoc.GetHtmlBody)
     else Add('<body>');
     GenerateForm(aForm,aYView,ARequest,AResponse,ErrorMessage);
     GenerateScript(aForm,aYView,HtmlDoc,ARequest,AResponse);
     Add('</body>');
     Add('</html>');
  end;
end;

{ TYServer }

constructor TYServer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  GenerateMainServerKey;
  LConnections := TStringList.Create;
  lTemporaryURL:= TStringList.Create;
  lCacheFiles:= TStringList.Create;
  MyCriticalSection := syncobjs.TCriticalSection.Create;
  LConnections.Sorted:= true;
  ConnectionTotal := 0;
  YFileLocationPath :=  ExtractFilePath(ParamStr(0))+CsFileLocation;
end;

function TYServer.UpdateConnectID(YHTMLID,aUserName : string ) : string;
begin
   if (YHTMLID = '') or (Copy(YHTMLID,1,1) = '_') then YHTMLID := UpdateModuloConnectionTotal;
   result := Copy(YHTMLID,1,4)+aUserName;
end;

procedure TYServer.UpdateFormYHTMLID(myForm : Tform);
var
    ConnectId : string;
    YHTMLID : string ;
begin
  if Assigned(myForm) then
  begin
    YHTMLID := myForm.Hint;
    if Copy(YHTMLID,1,1) = '-' then myForm.Hint := Copy(YHTMLID,2,255)
    else
    begin
      ConnectId  := ExctractConnectID(YHTMLID);
      if ConnectId = '' then myForm.Hint := '_'+myForm.ClassName
      else myForm.Hint := UpdateModuloConnectionTotal+ConnectId;
    end;
  end;
end;

procedure TYServer.StoreForm(myForm : Tform );
var
    ConnectId : string;
    ConnectIndex : integer;
    YHTMLID : string;
begin
  if Assigned(myForm) then
  begin
    YHTMLID := myForm.Hint;
    ConnectId  := ExctractConnectID(YHTMLID);
    ConnectIndex := LConnections.IndexOf(ConnectId);
    if (ConnectIndex >= 0) then
    begin
       LConnections.Objects[ConnectIndex] := myForm;
    end
    else
    begin
      if ConnectId <> '' then LConnections.AddObject(ConnectId,myForm) else myForm.Free;
    end;
  end;
end;

function  TYServer.GetConnectionCount : integer;
begin
  result := LConnections.Count;
end;


function TYServer.GetActive: Boolean;
begin
    result := factive;
end;

function TYServer.GetConnectionUser(ConnectionIndex:integer) : string;
begin
    result := '';
    try
       result := LConnections.Strings[ConnectionIndex];
    finally
    end;
end;

function TYServer.GetConnectionForm(ConnectionIndex:integer) : TForm;
begin
  result := nil;
  try
     result := TForm(LConnections.Objects[ConnectionIndex]);
  finally
  end;
end;

function TYServer.GetConnection(ARequest: TRequest;var YHTMLID : string) : TForm;
var ConnectId : string;
    ConnectIndex : integer;
begin
  YHTMLID := '';
  Result := nil;
  if ARequest.ContentFields.IndexOfName('YHTMLID') >=0 then
     YHTMLID :=  Decrypte( ARequest.ContentFields.Values['YHTMLID']);
  ConnectId := Copy(YHTMLID,5,255);
  ConnectIndex := LConnections.IndexOf(ConnectId);
  if (ConnectIndex >= 0) then
  begin
     Result := TForm(LConnections.Objects[ConnectIndex]);
     if assigned(Result) then
     begin
       ConnectId := Result.Hint;
       if (YHTMLID <> Result.Hint) and ('-'+YHTMLID <> Result.Hint) then Result := nil; //expirée
     end;
  end
end;

function TYServer.FindConnection(UserId: string) : TForm;
var ConnectIndex : integer;
begin
  Result := nil;
  ConnectIndex := LConnections.IndexOf(UserId);
  if (ConnectIndex >= 0) then
  begin
     Result := TForm(LConnections.Objects[ConnectIndex]);
  end
end;

function TYServer.NewConnection(UserId : string; WelcomeForm : TForm) : String;
begin
  LConnections.AddObject(UserId,WelcomeForm);
  Result := UpdateModuloConnectionTotal+UserId;
  if Assigned(WelcomeForm) then WelcomeForm.Hint := Result;
end;

procedure TYServer.RemoveConnection(UserId : string);
var ConnectIndex : integer;
begin
  ConnectIndex := LConnections.IndexOf(UserId);
  if (ConnectIndex >= 0) then
  begin
     LConnections.Delete(ConnectIndex);
  end
end;
function TYServer.GetModuloConnectionTotal : string;
var i: integer;
    modulo,reste : integer;
begin
  result := '';
  modulo := ConnectionTotal;
  for i := 1 to 4 do
  begin
      reste :=  modulo mod (26);
      modulo := modulo div (26);
      result := result + chr(reste+65);
  end;
end;

function TYServer.UpdateModuloConnectionTotal : string;
var i: integer;
    modulo,reste : integer;
begin
  MyCriticalSection.Enter;
  ConnectionTotal := ConnectionTotal+1;
  modulo := ConnectionTotal;
  MyCriticalSection.Leave;
  result := '';
  for i := 1 to 4 do
  begin
      reste :=  modulo mod (26);
      modulo := modulo div (26);
      result := result + chr(reste+65);
  end;
end;

procedure TYServer.SetActive(AValue: Boolean);
begin
   if factive = AValue then exit;
    factive := AValue;
    if not (csDesigning in Componentstate) then
      if (AValue=true) then
      begin
          DefaultFormatSettings.DecimalSeparator := '.';
          LeYServerThread :=TYServerThread.Create(self);
          LeYServerThread.LeYServer := self;
      end
      else
      begin
        LeYServerThread.LeHTTPServer.Active:=false;
//        LeHTTPServerThread.LeHTTPServer.Free;
//        LeHTTPServerThread.Terminate;
      end;
end;

procedure TYServer.RemoveCachedFile(Filename: string);
var lIndex : integer;
    mms : TMemoryStream;
begin
  MyCriticalSection.Enter;
  lIndex := lCacheFiles.IndexOf(Filename);
  if lIndex>0 then
  begin
     mms := TMemoryStream(lCacheFiles.Objects[lIndex]);
     mms.Free;
     lCacheFiles.Delete(lIndex);
  end;
  MyCriticalSection.Leave;
end;

function TYServer.GetCacheFile(Filename: string): TMemoryStream;
var lIndex : integer;
    mms : TMemoryStream;
begin
  lIndex := lCacheFiles.IndexOf(Filename);
  if lIndex>0 then
  begin
     result := TMemoryStream(lCacheFiles.Objects[lIndex]);
  end
  else
  begin
    if FileExists(Filename) then
    begin
      mms := TMemoryStream.Create;
      mms.LoadFromFile(Filename);
      lCacheFiles.AddObject(Filename,mms);
      result := mms;
    end
    else result := nil;
  end;
end;

procedure TYServer.SendFile(filename : string;AResponse: TResponse);
var block : boolean;
     FS : TFileStream;
     MMS,MMSource :  TMemoryStream;

     dumb : integer;
begin

  filename := StrReplace(filename,'/','\');
  if (LowerCase(ExtractFileExt(filename)) = '.svg') then AResponse.ContentType := 'image/svg+xml';
  if (LowerCase(ExtractFileExt(filename)) = '.png') then AResponse.ContentType := 'image/png';
  if (LowerCase(ExtractFileExt(filename)) = '.gif') then AResponse.ContentType := 'image/gif';
  if (LowerCase(ExtractFileExt(filename)) = '.pdf') then AResponse.ContentType := 'application/pdf';
  if (LowerCase(ExtractFileExt(filename)) = '.ico') then AResponse.ContentType := 'image/x-icon';
  AResponse.FreeContentStream:= true;
  block := false;
  AResponse.URL:=ExtractFileName(filename);
  if FileExists(filename) then
  begin
//    MyCriticalSection.Enter;
    try
//      AResponse.ContentStream :=  TFileStream.Create(filename,fmOpenRead,fmShareDenyNone);

      MMSource := GetCacheFile(filename);
      if Assigned(MMSource) then
      begin
        MMS := TMemoryStream.Create;
        MMS.CopyFrom(MMSource,0);
        AResponse.ContentStream := MMS;
        AResponse.FreeContentStream:=true;
      end;


      AResponse.SendContent;
      except
//        on E: Exception do
//          ShowMessage('An exception was raised: ' + E.Message);
      end;
//     MyCriticalSection.Leave;
  end;

  {
  if FileExists(filename) then
  begin
    try
      FS := TFileStream.Create(filename,fmOpenRead,fmShareDenyNone);
    except
      AResponse.ContentStream :=  nil;
      block := true;
    end;
    if block = false then
    try
      AResponse.ContentStream :=  FS;
    except
      FS.Free;
      AResponse.ContentStream :=  nil;
      block := true;
    end;
  end
  else block:= true;
  if block = false then
  try
    if Assigned(AResponse) then
    if Assigned(AResponse.ContentStream) then
      AResponse.SendContent;
  except
    FS.Free;
  end
  else     AResponse.Contents.Add('Erreur Fichier' + filename) ;  //nil;
    }
end;

{procedure TYServer.AddTemopraryURL(Urlname: string; filename: string);
begin
  lTemporaryURL.Values[Urlname] := filename;
end;

procedure TYServer.RemoveTemopraryURL(Urlname: string);
var lIndex : integer;
begin
  lIndex :=lTemporaryURL.IndexOfName(Urlname);
  if lIndex>=0 then lTemporaryURL.Delete(lIndex);
end;
 }

destructor TYServer.destroy;
begin
  lTemporaryURL.Free;
  LConnections.Free;
  inherited destroy;
end;

{ TYServerThread }

procedure TYServerThread.LeFPHttpServerRequest(Sender: TObject;
  var ARequest: TFPHTTPConnectionRequest;
  var AResponse: TFPHTTPConnectionResponse);
var myForm :  TForm;
    FormName : string;
    YHTMLID : string;
    ConnectID : string;
    ErrorMessage : string;
    MyYView : TYHtmlControl;
    myURI : string;
    URIPath : string;

    HtmlDoc : TYHtmlDocument;
    bNewForm : boolean;
    RefForm : Tform;
    bFromFormRequest : boolean;
begin
  bFromFormRequest := false;
  myForm := nil; HtmlDoc := nil; MyYView := nil;
  YHTMLID := '';  ErrorMessage := ''; ConnectID := '';
  myURI := ARequest.URI;
  StrToken(myURI,'/');
  URIPath := StrToken(myURI,'/');
  if URIPath = 'favicon.ico' then
  begin
    URIPath :=  CYURIFile ;
    myURI := 'favicon.ico';
  end;
  if LeYServer.lTemporaryURL.IndexOfName(URIPath)>=0 then
  begin
    LeYServer.SendFile(LeYServer.lTemporaryURL.Values[URIPath],AResponse);
  end
{  else
  if URIPath = 'pdf' then
  begin
    LeYServer.SendFile('pdf/'+myURI,AResponse);
  end }
  else
  if URIPath = CYURIFile then
  begin
    try
       if Assigned(LeYServer.FOnActivityMonitor) then LeYServer.FOnActivityMonitor(self.LeYServer,myURI,true,false);
       LeYServer.SendFile(LeYServer.YFileLocationPath+myURI,AResponse);
       if Assigned(LeYServer.FOnActivityMonitor) then LeYServer.FOnActivityMonitor(self.LeYServer,myURI,true,true);
    except
    end;
  end
  else if (URIPath = CYURIView) or (URIPath = '') then
  begin
    YHTMLID := Decrypte( ARequest.ContentFields.Values['YHTMLID']);
    myForm := LeYServer.GetConnection(ARequest,YHTMLID);
    ConnectID := ExctractConnectID(YHTMLID) ;
    if not Assigned(myForm) then
    begin    // fiche non connue
      ConnectID := ExctractConnectID(YHTMLID) ;
      FormName := '';
      if (ConnectID <> '') then
      begin
         if URIPath = '' then  myForm := YMessageInfo('Cette fenêtre a expirée !','')
         else
           ErrorMessage := 'Cette fenêtre a expirée !';
         ARequest.ContentFields.Clear;
         ConnectID := '';
      end
      else
      begin
         FormName:= YHTMLID;
         ConnectID := '';
         If Assigned(LeYServer.OnFormRequest ) then
         try
            LeYServer.OnFormRequest(Self,myForm,FormName);
            bFromFormRequest := true;
         except
            on E : Exception do
            begin
                 ErrorMessage := 'Exception class name = '+E.ClassName + '<br>'+'Exception message = '+E.Message+ '<br>';
            end
            else ErrorMessage := 'Erreur';
         end;
      end;
    end;
    if Assigned(LeYServer.FOnActivityMonitor) then LeYServer.FOnActivityMonitor(self.LeYServer,ConnectID,false,false);
    if Assigned(myForm) then
    begin
      if (URIPath = CYURIView) then
      begin
        MyYView := FindYView(myForm,ARequest.ContentFields.Values['YHTMLVIEWNAME'] );
      end;
      while copy(myForm.Hint,1,1) = '-' do
      begin    // attente de fin de traitement en cours
          Sleep(500);
      end;
    end;
    if (not Assigned(MyYView)) and (URIPath = CYURIView) and (ErrorMessage = '') then
        with AResponse.Contents do    // View s'initialise
        begin
          Add('<!DOCTYPE html>'); Add('<html>'); Add('<head>'); Add('</head>'); Add('<body>');
          Add('<form action="' + ARequest.URI + '" method="POST">');
          Add('<input id="idYHTMLID" name="YHTMLID" value="YHTMLID" style = "visibility: hidden;position:absolute;" >');
          Add('<input name="YHTMLEXIT" type="submit" id="idYHTMLEXIT" value="YHTMLEXIT" style = "visibility: hidden;position:absolute;">');
          Add('<input name="YHTMLVIEWNAME" name="YHTMLVIEWNAME" id="idYHTMLVIEWNAME" value="YHTMLVIEWNAME" style = "visibility: hidden;position:absolute;">');
          Add('×');
          Add('</form>');
          Add('<script>');
          Add('document.getElementById("idYHTMLID").value = parent.document.getElementById("idYHTMLID").value;');
          Add('document.getElementById("idYHTMLVIEWNAME").value = window.frameElement.name;');
          Add('var  myExit = document.getElementById("idYHTMLEXIT");');
          Add('myExit.value = "YVIEW";');
          Add('myExit.click();');
          Add('</script>');
          Add('</body>');
          Add('</html>');
        end
    else
    begin
      if not Assigned(myForm) then
      begin
        if ErrorMessage = '' then ErrorMessage := 'Erreur serveur : FormRequest vide' ;
        myForm := TForm.Create(self.LeHTTPServer); //YMessageInfo('','')
      end
      else
      begin
       HtmlDoc := FillForm(myForm, ARequest,ErrorMessage);
       bNewForm := false; // navigation fiche suivante
       if Assigned(HtmlDoc ) then
       begin
            HtmlDoc.LeYServer := Self.LeYServer;
            bNewForm := (HtmlDoc.NextForm <> myForm) and Assigned(HtmlDoc.NextForm);
            if (not Assigned(MyYView)) and (HtmlDoc.AllowNavigateBack = false) then
            LeYServer.UpdateFormYHTMLID(myForm);
       end
       else
       begin
          if not Assigned(MyYView) then LeYServer.UpdateFormYHTMLID(myForm);
       end;
                        // Reconexion
       RefForm := LeYServer.FindConnection(ExctractConnectID(myForm.Hint));
       if Assigned(RefForm) and (myForm<>RefForm)  then
       begin
          if bFromFormRequest = true then myForm.Free;
          myForm := RefForm;
          bNewForm :=false;
          ARequest.ContentFields.Clear;
          FindYHtmlDocument(myForm,HtmlDoc);
       end;
       if (bNewForm= true) then
       begin
         if Assigned( MyYView) then
         begin
           with AResponse.Contents do    // View s'initialise
           begin
             Add('<!DOCTYPE html>'); Add('<html>'); Add('<head>'); Add('</head>'); Add('<body>');
             Add('<form action="' + ARequest.URI + '" method="POST">');
             Add('×');
             Add('</form>');
             Add('<script>');
             Add('parent.RefreshMe("!");');
             Add('</script>');
             Add('</body>');
             Add('</html>');
           end;
           myForm := nil;
         end
         else
         begin
            RefForm :=  myForm;
            myForm := HtmlDoc.NextForm;
            myForm.Hint:= RefForm.Hint;
            LeYServer.StoreForm(myForm);
            if HtmlDoc.NextForm = HtmlDoc.ReturnFrom then
            begin       // libération de fiche en retour
              ARequest.ContentFields.Clear;
              FindYHtmlDocument(myForm,HtmlDoc);
              try
                 if Assigned(HtmlDoc.OnReturn) then HtmlDoc.OnReturn(RefForm);
              except
                 on E : Exception do
                 begin
                      ErrorMessage := ErrorMessage+'Exception class name = '+E.ClassName + '<br>'+'Exception message = '+E.Message+ '<br>';
                 end
                 else ErrorMessage := ErrorMessage+'Erreur<br>';
              end;
              RefForm.Free;RefForm := nil;
            end
            else
            begin
              HtmlDoc.NextForm := Nil;
            end;
            ARequest.ContentFields.Clear;
            FindYHtmlDocument(myForm,HtmlDoc);
            if Assigned(HtmlDoc ) and Assigned(RefForm) then HtmlDoc.ReturnFrom := RefForm;
         end;
       end;
      end;

      if Assigned(myForm) then
      if myForm.Enabled = true then
      begin
        if Assigned(HtmlDoc) then
        begin
          myForm.Enabled:= false;
          myURI :='';
          try
            if Assigned(HtmlDoc.OnGenerateHTML) then HtmlDoc.OnGenerateHTML(HtmlDoc);
          except
            on E : Exception do
                begin
                  ErrorMessage := ErrorMessage+E.ClassName + ' signale :<br>'+E.Message+ '<br>';
                end;
          end;
          myForm.Enabled:= true;
          myURI := HtmlDoc.NextURI;
          HtmlDoc.NextURI := '';
        end;
        if Assigned(MyYView) and (MyYView is TYView) then
        begin
          if Assigned(TYView(MyYView).OnGenerateHTML) then TYView(MyYView).OnGenerateHTML(MyYView);
          myURI:= TYView(MyYView).ContentFile;
        end;
//        if ErrorMessage <> '' then myForm := YMessageInfo(ErrorMessage,myForm.Hint);
        if myURI = '' then
           GeneratePage(myForm,MyYView,HtmlDoc,ARequest,AResponse,ErrorMessage)
        else
        begin
          LeYServer.SendFile(myURI,AResponse);
          myURI := AResponse.RemoteAddr;
          myURI := AResponse.RemoteAddress;
          myURI := AResponse.ContentLocation;
          myURI := AResponse.URL;
        end;
        LeYServer.StoreForm(myForm);  // sauvegarde ou libère la fiche
      end
      else
      begin
         YHTMLID := myForm.Hint;
         if copy(myForm.Hint,1,1) <> '-' then
           myForm.Hint := '-' + myForm.Hint;
         myForm := YMessageInfo('Traitement en cours...', YHTMLID);
         ARequest.ContentFields.Clear;
         FindYHtmlDocument(myForm,HtmlDoc);
         GeneratePage(myForm,MyYView,HtmlDoc,ARequest,AResponse,ErrorMessage);
         myForm.Free;
      end;
    end;
    if Assigned(LeYServer.FOnActivityMonitor) then LeYServer.FOnActivityMonitor(self.LeYServer,ConnectID,false,true);
  end;
end;



function TYServerThread.YMessageInfo(AMessage: string; aYHTMLID: string): TForm;
begin
  Result := TForm.Create(self.LeHTTPServer);
  Result.Hint:= aYHTMLID;
  with TYText.Create(Result) do try
    Parent := Result;
    HtmlStyle.font_size:= 14;
    Text:= StrReplace(AMessage,#13#10,'<br>') + '<br><br>';
  except end;
  with TYButton.Create(Result) do try
    Name:= 'YHTMLOK';
    Parent := Result;
    HtmlStyle.position_width:= '120px';
    HtmlStyle.position_height:= '120px';
    Text:= 'OK';
    TabStop:= true;
    ShortcutKeyCode:= 27;
  except end;
  with TYHtmlDocument.Create(Result) do try
     Name:= 'YHTMLDOC';
     UseYFocus:= true;
     CurrentFocus:= 'YHTMLOK';
  except end;
end;

constructor TYServerThread.Create(owner : TComponent);
begin
  LeHTTPServer := TFPHTTPServer.Create(owner);
  LeHTTPServer.Threaded := true;
  inherited Create(false);
  FreeOnTerminate:= true;
end;

destructor TYServerThread.Destroy;
begin
  inherited Destroy;
end;

procedure TYServerThread.Execute;
begin
  try
    LeHTTPServer.OnRequest := @LeFPHttpServerRequest;
    LeHTTPServer.ServerBanner:= 'YHTML';
    LeHTTPServer.QueueSize:=200;
    LeHTTPServer.Active := true;
  except
    on E: Exception do
    begin
      _Error := E.Message;
    end;
  end;
  FreeAndNil(LeHTTPServer);
end;


end.
