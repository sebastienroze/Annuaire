unit YJavascript;

{$mode objfpc}{$H+}

interface

uses
  YHtmlComponent,YSound,YHtmlControl,YClass,yTimer,YText,YCanvas,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;

type

  { TYJavascript }

  TYJavascript = class(TYHtmlComponent)
  private
//    function GetParentView: TYView;
//    procedure SetParentView(AValue: TYView);
  protected
    fCode : String ;
    fAutoclear : boolean;
  public
    destructor Destroy; override;
    function Yscript : string; override;
    procedure PlayYSound(aYSound : TYSound);
    procedure ApplyHtmlStyle(aYHtmlControl : TYHtmlControl;aYHtmlStyle :TYHtmlStyle);
    procedure ModifyHtmlStyle(aYHtmlControl : TYHtmlControl;aCSSStyle,aValue :string);
    procedure ModifyYTimer(aYTimer : TYTimer ;anInterval : integer);
    procedure ModifyYText(aYText : TYText;aText : string);
    procedure SelectCanvasContext(aCanvas : TYCanvas);
  published
    constructor Create(TheOwner: TComponent);override;
    property Code : String read fCode write fCode;
    property Autoclear : boolean read fAutoclear write fAutoclear;
//    property ParentView : TYView read GetParentView write SetParentView;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$I yjavascript_icon.lrs}
  RegisterComponents('YHTML',[TYJavascript]);
end;

{ TYJavascript }

{function TYJavascript.GetParentView: TYView;
begin
  Result := TYView(fParentView);
end;

procedure TYJavascript.SetParentView(AValue: TYView);
begin
  fParentView := AValue;
end;
 }
destructor TYJavascript.Destroy;
begin
    inherited Destroy;
end;

function TYJavascript.Yscript: string;
begin
  Result:=fCode;
  if fAutoclear = true then fCode:= '';
end;

procedure TYJavascript.PlayYSound(aYSound: TYSound);
begin
  fCode := fCode+ 'var ysound = '+JVS_ParentForm+aYSound.JVS_getElementById+';';
  fCode := fCode+ 'ysound.pause();ysound.currentTime = 0;ysound.play();';
end;

procedure TYJavascript.ApplyHtmlStyle(aYHtmlControl: TYHtmlControl;
  aYHtmlStyle: TYHtmlStyle);
var sValue : String;
begin
  if aYHtmlStyle.Hidden = true then sValue := '"hidden"' else sValue := '"visible"';
  fCode := fCode+ JVS_ParentForm+aYHtmlControl.JVS_getElementById +'.style.visibility = ' + sValue + ';';
end;

procedure TYJavascript.ModifyHtmlStyle(aYHtmlControl: TYHtmlControl; aCSSStyle,
  aValue: string);
begin
  fCode := fCode+ JVS_ParentForm+aYHtmlControl.JVS_getElementById +'.style.'+aCSSStyle+' = "' + aValue + '";';
end;

procedure TYJavascript.ModifyYTimer(aYTimer: TYTimer; anInterval: integer);
begin
   fCode := fCode+JVS_ParentForm + 'ModifiyTimer_'+aYTimer.Name+'('+IntToStr(anInterval)+ ');';
//  fCode := fCode+ 'clearTimeout('+JVS_ParentForm + 'var'+aYTimer.Name+');';
//  fCode := fCode+JVS_ParentForm + 'var'+aYTimer.Name+' = setInterval('+JVS_ParentForm+'Timer_'+aYTimer.Name+','+ IntToStr(anInterval)+ ');';
end;

procedure TYJavascript.ModifyYText(aYText: TYText; aText: string);
begin
  fCode := fCode+ JVS_ParentForm+aYText.JVS_getElementById +'.innerText = "' + aText + '";';
end;

procedure TYJavascript.SelectCanvasContext(aCanvas: TYCanvas);
begin
  fCode := fCode + 'var y_canvas = '+JVS_ParentForm+'document.getElementById("id'+aCanvas.Name+'");';
//   fCode := fCode + 'var y_canvas = parent.document.getElementById("id'+aCanvas.Name+'");';
   fCode := fCode +'var y_ctx = y_canvas.getContext("2d");';
end;

constructor TYJavascript.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
end;

end.
