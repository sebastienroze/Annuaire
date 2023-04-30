unit YHtmlDocument;

{$mode objfpc}{$H+}

interface

uses
  YClass,YServer,YHtmlControl,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;


type


  { TYHtmlDocument }

  TYHtmlDocument = class(TComponent)
  private
    FAllowNavigateBack: boolean;
    fClass : TYClass;
    fClassMulti : string;
    fGenerateHTML : TYHtmlEvent;
    fOnReturn : TYHtmlEvent;
    fCurrentFocus : string;
    fUseYFocus : boolean;
    fcss :Tstrings;
    procedure SetAllowNavigateBack(AValue: boolean);
    procedure Setfcss(AValue: tStrings);
  protected
    fHtmlStyle : TYHtmlStyle;
    fAlertMessage : string;
    procedure Loaded; override;
  public
    YWindowSize : string;
    ReturnFrom  : Tform;
    NextForm : Tform;
    NextURI : string;
    LeYServer : TYServer;
    constructor Create(TheOwner: TComponent);override;
    destructor Destroy; override;
    function Yscript: string;
    function GetHtmlBody : string;
    function GetUsername : string;
    procedure SetUserName(aUserName : string);
    procedure Return;
    procedure DisplayAlert(aMessage : string);
    procedure AddCss({%H-}Lines: TStrings); virtual;
  published
    property HtmlStyle : TYHtmlStyle read fHtmlStyle write fHtmlStyle;
    property HtmlClass : TYClass read fClass write fClass;
    property HtmlClassMulti : string read fClassMulti write fClassMulti;
    property UserName:string read GetUsername write SetUserName;
    property OnGenerateHTML : TYHtmlEvent read fGenerateHTML write fGenerateHTML;
    property OnReturn : TYHtmlEvent read fOnReturn write fOnReturn;
    property CurrentFocus : string read fCurrentFocus write fCurrentFocus;
    property UseYFocus : boolean read fUseYFocus write fUseYFocus;
    property CSS : tStrings read fcss write Setfcss;
    property AllowNavigateBack : boolean read FAllowNavigateBack write SetAllowNavigateBack;
  end;

procedure FindYHtmlDocument(aForm : TControl; var HtmlDoc : TYHtmlDocument);

procedure Register;

implementation

uses strutils;

procedure Register;
begin
  {$I yhtmldocument_icon.lrs}
  RegisterComponents('YHTML',[TYHtmlDocument]);
end;

procedure FindYHtmlDocument(aForm : TControl ; var HtmlDoc : TYHtmlDocument);
var
  i : integer;
begin
  for i := 0 to aForm.ComponentCount  -1 do
  begin
    if (aForm.Components[i] is TYHtmlDocument) then HtmlDoc := TYHtmlDocument(aForm.Components[i])
  end;
end;

{ TYHtmlDocument }

constructor TYHtmlDocument.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  fHtmlStyle := TYHtmlStyle.Create;
  NextForm := nil;
  ReturnFrom  := nil;
  YWindowSize := '';
  fAlertMessage:= '';
  NextURI := '';
  fcss := tstringlist.Create;
end;

destructor TYHtmlDocument.Destroy;
begin
  try
    fcss.free;
  except
  end;
  inherited Destroy;
end;

function TYHtmlDocument.Yscript: string;
begin
  if fAlertMessage <> '' then
  Result := 'alert("'+StringReplace(fAlertMessage,#13#10,'\n',[rfReplaceAll])+'");'
  else Result := '';
  fAlertMessage := '';
end;

procedure TYHtmlDocument.Setfcss(AValue: tStrings);
begin
  fcss.Text :=AValue.Text;
end;

procedure TYHtmlDocument.SetAllowNavigateBack(AValue: boolean);
begin
  if FAllowNavigateBack=AValue then Exit;
  FAllowNavigateBack:=AValue;
end;

procedure TYHtmlDocument.Loaded;
var
 // scolor : string;
  MyHtmlStyle : TYHtmlStyle;
  i : integer;
begin
  inherited Loaded;
  if  (csDesigning in ComponentState)  then
  begin
    if (Owner is TForm) then
    begin
      MyHtmlStyle := TYHtmlStyle.Create;
      MyHtmlStyle.Clear;
      with GetListHtmlStyles(TWinControl(self.Owner),Self.HtmlClass,Self.HtmlClassMulti) do
      try
        for i := 0 to Count -1 do
        begin
           MyHtmlStyle.AddHtmlStyle(TYHtmlStyle(Objects[i]));
        end;
      finally
        free;
      end;
      TForm(Owner).Color:= clWhite;
      if MyHtmlStyle.background_color<> '' then TForm(Owner).Color:= Htmlcolor(MyHtmlStyle.background_color);
      MyHtmlStyle.Free;
    end;
  end;
end;

function TYHtmlDocument.GetHtmlBody: string;
var sStyle,sclass : string;
begin
  sStyle := fHtmlStyle.EncodeHtmlStyle;
  sclass :=   EncodeYHtmlClass(HtmlClass,fClassMulti);
  if (sclass <> '' ) or (sStyle <> '' ) then
  begin
     Result := '<body ' + sclass + ' '+sStyle+ '>';
  end else Result := '<body>';
end;

function TYHtmlDocument.GetUsername: string;
var YHTMLID : string;
begin
  result :='';
  if (Owner is TForm) then
  begin
    YHTMLID := TForm(Owner).Hint;
    result := ExctractConnectID(YHTMLID);
  end;
end;

procedure TYHtmlDocument.SetUserName(aUserName: string);
var YHTMLID : string;
  oldUserName : string;
begin
  if (Owner is TForm) then
  begin
    YHTMLID := TForm(Owner).Hint;
    oldUserName := ExctractConnectID(YHTMLID);
    if (oldUserName<>'') and (oldUserName <>aUserName) then LeYServer.RemoveConnection(oldUserName);
    if (aUserName = '') then YHTMLID := '_'+TForm(Owner).ClassName
    else YHTMLID := LeYServer.UpdateConnectID(YHTMLID,aUserName);
    TForm(Owner).Hint := YHTMLID;
  end
end;

procedure TYHtmlDocument.Return;
begin
    NextForm := ReturnFrom;
end;

procedure TYHtmlDocument.DisplayAlert(aMessage: string);
begin
  if fAlertMessage<> '' then   fAlertMessage:=   fAlertMessage+'\n';
  fAlertMessage:= fAlertMessage + aMessage;
end;

procedure TYHtmlDocument.AddCss(Lines: TStrings);
var i : integer;
begin
  for i := 0 to fcss.Count-1 do
    Lines.Add(fcss.Strings[i]);
end;

end.
