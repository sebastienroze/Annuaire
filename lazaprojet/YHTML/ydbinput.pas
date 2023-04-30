unit YDBInput;

{$mode objfpc}{$H+}

interface

uses
  DbCtrls,db,YHtmlControl,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, YInput;

type

  { TYDBInput }

  TYDBInput = class(TYInput)
  private
    FDataLink: TFieldDataLink;
    function GetDataField: string;
    function GetDataSource: TdataSource;
    procedure SetDataField(const Value: string);
    procedure SetDataSource(const Value: TdataSource);
  protected

  public
      procedure Paint; override;
      procedure UpdateField(var ErrorMessage : string);
      destructor Destroy; override;
      procedure FillFromRequest(ARequestContent : TStrings; var vOnClick : TYHtmlEvent;var Sender:TObject;YHTMLEXIT : string;var ErrorMessage : string);override;
  published
    constructor Create(AOwner : TComponent); override;
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    function YHTML: string;override;
  end;

procedure Register;

implementation

uses strprocs;

procedure Register;
begin
  {$I ydbinput_icon.lrs}
  RegisterComponents('YHTML',[TYDBInput]);
end;

{ TYDBInput }

function TYDBInput.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TYDBInput.GetDataSource: TdataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TYDBInput.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

procedure TYDBInput.SetDataSource(const Value: TdataSource);
begin
  FDataLink.DataSource := Value;
end;

procedure TYDBInput.Paint;
var
  sFontname : string;
  txt : string;
begin
  inherited Paint;
  if  (csDesigning in ComponentState)  then
  begin
    Canvas.Pen.Color:= clBlack;
    Canvas.Brush.Color:= clWhite;
    Canvas.Rectangle(0,0,Width,Height);
    if DataField = '' then txt := Name else txt := DataField;
    if (txt<> '') then
    begin
      sFontname := IdeStyle.font_family;
      if sFontname = '' then sFontname := 'Times New Roman';
      Canvas.Font.Color:= clBlack;
      Canvas.Font.Name := sFontname;
      Canvas.Font.Style:= IdeStyle.font_style;
      if (Canvas.Font.Size <> IdeStyle.font_size) then SetBounds(Left,Top,Width,Height);
      Canvas.TextOut(2,2,txt);//
    end;
  end;     end;

procedure TYDBInput.UpdateField(var ErrorMessage : string);
begin
    if (DataSource.DataSet.State = dsInsert) or (DataSource.DataSet.State = dsEdit )  or (DataSource.AutoEdit = true) then
    begin
      if (FDataLink.Field.ReadOnly= false) and (FDataLink.Field.FieldKind <> fkCalculated )  then
      try
{        if (FDataLink.Field.FieldDef.DataType = ftFloat) then
        begin
          fText:= StrReplace(fText,'.',DefaultFormatSettings.DecimalSeparator);
        end;  }
        if V2S(FDataLink.Field.AsVariant)<> fText then
        begin
           if (DataSource.AutoEdit = true)  and (DataSource.DataSet.State = dsBrowse) then DataSource.DataSet.Edit;
           FDataLink.Field.Text:= fText;
        end;
      except
          on E : Exception do
              begin
                ErrorMessage := ErrorMessage+E.ClassName + ' signale :<br>'+E.Message+ '<br>';
              end;
      end;
    end;
end;

constructor TYDBInput.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  height := 23;
end;

destructor TYDBInput.Destroy;
begin
  try
  FDataLink.Free;
  except
  end;
  inherited Destroy;
end;

procedure TYDBInput.FillFromRequest(ARequestContent: TStrings;
  var vOnClick: TYHtmlEvent; var Sender: TObject; YHTMLEXIT: string;var ErrorMessage : string);
begin
  inherited FillFromRequest(ARequestContent, vOnClick, Sender, YHTMLEXIT,ErrorMessage);
  if Self.Generate = false then exit;
  if Self.fReadOnly = true then exit;
  if ARequestContent.IndexOfName(Name) >= 0 then
    UpdateField(ErrorMessage);
end;

function TYDBInput.YHTML: string;
var ForceReadonly : Boolean;
    svalStep : string;
    NbDigits : integer;
    sformatfloat : string;
begin
  fText := '';
  if not Assigned(FDataLink) then Exit;
  if not Assigned(FDataLink.Field) then Exit;
  try
    if (fInputType = TYitNumber) and isNumeric(fValueStep) then
    begin
       svalStep := fValueStep;
       StrToken(svalStep,'.');
       NbDigits := Length(svalStep);
       if NbDigits>0 then sformatfloat := '0.'+StrPad('0','0',NbDigits)
       else sformatfloat := '';
       fText:= FormatFloat(sformatfloat,V2Flt(FDataLink.Field.AsVariant)) ;
    end
    else
//      fText := v2s(FDataLink.Field.AsVariant );
        fText := FDataLink.Field.Text;

{    if (FDataLink.Field.FieldDef.DataType = ftFloat) then
    begin
      fText:= StrReplace(fText,DefaultFormatSettings.DecimalSeparator,',');
    end;   }
  except
    fText := '';
  end;
  ForceReadonly := fReadOnly;
  if (FDataLink.DataSet.State = dsBrowse) or
     (FDataLink.DataSet.State = dsInactive) then fReadOnly := true;
  if Assigned(FDataLink.DataSource) then
    if (FDataLink.DataSource.AutoEdit = true) and (FDataLink.DataSet.State = dsBrowse) then
    fReadOnly := ForceReadonly;

  if (FDataLink.Field.ReadOnly= true) then fReadOnly := true;

  Result:=inherited YHTML;
  fReadOnly := ForceReadonly;
end;

end.
