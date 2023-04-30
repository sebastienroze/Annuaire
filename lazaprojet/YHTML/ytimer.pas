unit YTimer;

{$mode objfpc}{$H+}

interface

uses
  YView,YHtmlControl,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;

type

  { TYTimer }

  TYTimer = class(TYHtmlComponent)
  private

  protected
    fOnTime : TYHtmlEvent;
    fTargetView : TYView;
    fInterval : integer;
  public
    function Yscript : string; override;
    procedure FillFromRequest(ARequestContent : TStrings; var vOnClick : TYHtmlEvent;var Sender:TObject;YHTMLEXIT : string);override;
  published
    property OnTime : TYHtmlEvent read fOnTime write fOnTime;
    property TargetView : TYView read fTargetView write fTargetView;
    property Interval : integer read fInterval write fInterval;
  end;

procedure Register;

implementation



procedure Register;
begin
  {$I ytimer_icon.lrs}
  RegisterComponents('YHTML',[TYTimer]);
end;

{ TYTimer }

function TYTimer.Yscript: string;
var sTmp  : string;
  sparent : string;
begin
  Result := '';
  if Self.Generate = false then exit;
  if Assigned(fOnTime)then
  begin
    if Assigned(fParentView) then sparent:= 'parent.'+fParentView.JVS_ParentForm + sTmp else sparent := '';
    if Interval = 0 then
    begin
      Result:= 'var var'+Name+' = 0;';
    end
    else
    begin
       Result:= 'var var'+Name+' = setInterval(Timer_'+Name+','+ IntToStr(Interval)+ ');';
    end;
    result := result +'function Timer_'+Name+'() {';

    sTmp := 'RefreshMe("timer_'+name+'");';
    if  Assigned(fTargetView) then sTmp:= 'if ('+sparent+fTargetView.Name+'_loaded == 1) {'+sparent+fTargetView.JVS_getElementById+'.contentWindow.'+sTmp+'}';
    result := result +sTmp+'}';
    result := result +'function ModifiyTimer_'+Name+'(TimerInterval) {if (var'+Name+' !=0) { clearTimeout(var'+Name+');}';
    result := result +'if (TimerInterval ==0) {var'+Name+'=0;} else {';
    result := result + 'var'+Name+' = setInterval(Timer_'+Name+',TimerInterval);}}';
  end;
end;

procedure TYTimer.FillFromRequest(ARequestContent: TStrings;
  var vOnClick: TYHtmlEvent;var Sender:TObject; YHTMLEXIT: string);
begin
  if (YHTMLEXIT = 'timer_'+name) then if Assigned(fOnTime) then
  begin
    vOnClick := TYHtmlEvent(fOnTime);
    Sender := self;
  end;
end;

end.
