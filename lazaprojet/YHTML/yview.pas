unit YView;

{$mode objfpc}{$H+}

interface

uses
  YHtmlControl,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;

type

  { TYView }

  TYView = class(TYCustomView)
  private
    fGenerateHTML : TYHtmlEvent;
    fContentFile : string;
  protected

  public
    procedure Paint; override;
    function YHTML: string;override;
    function Yscript: string; override;
    function FindYViewParent :  TWinControl;
//    function JVS_ParentForm : string;
  published
    property OnGenerateHTML : TYHtmlEvent read fGenerateHTML write fGenerateHTML;
    property ContentFile : string read fContentFile write fContentFile;
    constructor Create(TheOwner: TComponent);override;
    property TabStop;
  end;


procedure Register;
function FindYView(aForm : TForm;aYViewName : string) : TYHtmlControl;

implementation

procedure Register;
begin
  {$I yview_icon.lrs}
  RegisterComponents('YHTML',[TYView]);
end;

function FindYView(aForm : TForm;aYViewName : string) : TYHtmlControl;
var
    i : integer;
begin
     Result := nil;
     if assigned(aForm) then
     begin
       for i := 0 to aForm.ComponentCount -1 do
       begin
        if aForm.Components[i] is TYHtmlControl then
        begin
          if  TYHtmlControl(aForm.Components[i]).Name = aYViewName then Result := TYHtmlControl(aForm.Components[i]);
        end;
{         if aForm.Components[i] is TYView then
         begin
           if  TYView(aForm.Components[i]).Name = aYViewName then Result := TYView(aForm.Components[i]);
         end;  }
       end;
     end;
end;

{ TYView }

constructor TYView.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  RefreshParent := false;
  RefreshMe := false;
  BrBefore := false;BrAfter := false;
  YWindowSize := '';
  FocusEnabled := true;
//  UseFocusKeys := true;
end;

procedure TYView.Paint;
begin
  inherited Paint;
  if  (csDesigning in ComponentState)  then
  begin
     Canvas.Rectangle(0,0,Width,Height);
  end;
end;

function TYView.YHTML: string;
begin
{   if ContentFile <> '' then
   begin
     result := '<iframe name="' +Name + '"  id="id' +Name +'" '+EncodeHtmlClassStyle + ' frameBorder="0" src="'+ContentFile +'"> <p>Your browser does not support iframes.</p></iframe>'
   end
   else
   }
   result := '<iframe name="' +Name + '"  id="id' +Name +'" '+EncodeHtmlClassStyle + ' frameBorder="0" src="/view/'+ExtractFileName(ContentFile) +'"> <p>Your browser does not support iframes.</p></iframe>';
end;

function TYView.Yscript: string;
begin
  Result:= '';
//  Result:= 'var ' + Name + '_loaded = 0;';
end;

function TYView.FindYViewParent: TWinControl;
begin
   result := nil;
   if Assigned(Parent) then
   begin
     result := Parent;
     while assigned(Result.Parent) and
         (not (result is TForm)) and
         (not (result is TYView)) do
     begin
       result := result.Parent
     end;
   end;
end;
{
function TYView.JVS_ParentForm: string;
var     myCtrl : TWinControl;
begin
  result := 'parent';
  myCtrl :=  self;
  while not (myCtrl is TForm) do
  begin
     myCtrl := myCtrl.Parent;
     if myCtrl is TYView then
     begin
        result := 'parent.'+result;
     end;
  end;
end;
 }

end.
