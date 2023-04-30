unit YKeyboard;

{$mode objfpc}{$H+}

interface

uses YHtmlComponent,YView,YHtmlControl,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;

const
  YK_Space = '32';
  YK_Left = '37';
  YK_Up = '38';
  YK_Right = '39';
  YK_Down = '40';
type

  { TYKeyboard }

  TYKeyboard = class(TYHtmlComponent)
  private
        procedure SetfKeyList(AValue: tStrings);
      protected
        fOnKey : TYHtmlEvent;
        fTargetView : TYView;
        fKeyList : TStrings ;
      public
        Key : string;
        destructor Destroy; override;
        function Yscript : string; override;
        procedure FillFromRequest(ARequestContent : TStrings; var vOnClick : TYHtmlEvent;var Sender:TObject;YHTMLEXIT : string);override;
      published
        constructor Create(TheOwner: TComponent);override;
        property OnKey : TYHtmlEvent read fOnKey write fOnKey;
        property TargetView : TYView read fTargetView write fTargetView;
        property KeyList : TStrings read fKeyList write SetfKeyList;
  end;

procedure Register;

implementation

uses strprocs;
procedure Register;
begin
  {$I ykeyboard_icon.lrs}
  RegisterComponents('YHTML',[TYKeyboard]);
end;

{ TYKeyboard }

function TYKeyboard.Yscript: string;
var i : integer;
 sTmp  : string;
 sparent : string;

begin
  Result := '';
  if Assigned(fOnKey) and (fKeyList.Count >0) then
  begin
    if Assigned(fParentView) then sparent:= 'parent.'+fParentView.JVS_ParentForm + sTmp else sparent := '';
    Result:= 'var keydisabled'+Name+'=false;document.onkeydown = checkKey_'+Name+';function checkKey_'+Name+'(e) {e = e || window.event;';
    Result:=Result+'var x = e.charCode || e.keyCode;if(';
    for i := 0 to fKeyList.Count -1 do
    begin
      if i >0 then Result:=Result+' || ';
      Result:=Result+'(x == '+fKeyList.Strings[i] +')';
    end;
    Result:=Result+') {';
    Result:=Result+'e.preventDefault();';
    sTmp := 'RefreshMe("keyboard_'+name+':"+ x);';
    if  Assigned(fTargetView) then sTmp:= 'if ('+sparent+fTargetView.Name+'_loaded == 1) {'+sparent+fTargetView.JVS_getElementById+'.contentWindow.'+sTmp+'}';
    Result:=Result+'if (!keydisabled'+Name+'){'+sTmp+'}';
    Result:=Result+'}}';
  end;
end;

procedure TYKeyboard.FillFromRequest(ARequestContent: TStrings;
  var vOnClick: TYHtmlEvent;var Sender:TObject; YHTMLEXIT: string);
var stmp : string;
begin
  inherited FillFromRequest(ARequestContent, vOnClick,Sender, YHTMLEXIT);
  if Self.Generate = false then exit;
    if Assigned(fOnKey) then
    begin
        stmp := StrToken(YHTMLEXIT,':');
        if stmp = ('keyboard_'+name) then
        begin
           Key := YHTMLEXIT;
           vOnClick := TYHtmlEvent(fOnKey);
           Sender := self;
        end;
    end;
end;

constructor TYKeyboard.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  fKeyList := TStringList.Create;
  Key:= '';
end;

procedure TYKeyboard.SetfKeyList(AValue: tStrings);
begin
  fKeyList.Text :=AValue.Text;
end;

destructor TYKeyboard.Destroy;
begin
  try
    fKeyList.free;
  finally
    inherited Destroy;
  end;
end;

end.
