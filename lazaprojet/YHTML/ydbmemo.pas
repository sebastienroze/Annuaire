unit YDBMemo;

{$mode objfpc}{$H+}

interface

uses
  YHtmlControl,
  DbCtrls,db,  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, YMemo;

type

  { TYDBMemo }

  TYDBMemo = class(TYMemo)
  private

  protected
    FDataLink: TFieldDataLink;
    function GetDataField: string;
    function GetDataSource: TdataSource;

    procedure SetDataField(const Value: string);
    procedure SetDataSource(const Value: TdataSource);

  public
    procedure UpdateField(var ErrorMessage : string);
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure FillFromRequest(ARequestContent : TStrings; var vOnClick : TYHtmlEvent;var Sender:TObject;YHTMLEXIT : string;var ErrorMessage : string);override;
  published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    function YHTML: string;override;

  end;

procedure Register;

implementation

uses strprocs;

procedure Register;
begin
  {$I ydbmemo_icon.lrs}
  RegisterComponents('YHTML',[TYDBMemo]);
end;

{ TYDBMemo }

function TYDBMemo.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TYDBMemo.GetDataSource: TdataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TYDBMemo.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

procedure TYDBMemo.SetDataSource(const Value: TdataSource);
begin
  FDataLink.DataSource := Value;
end;

procedure TYDBMemo.UpdateField(var ErrorMessage : string);
begin
  begin
      if (DataSource.DataSet.State = dsInsert) or (DataSource.DataSet.State = dsEdit )  or (DataSource.AutoEdit = true) then
      begin
        if (FDataLink.Field.ReadOnly= false) and (FDataLink.Field.FieldKind <> fkCalculated )  then
        try
          if V2S(FDataLink.Field.AsVariant)<> Lines.Text then
          begin
             if (DataSource.AutoEdit = true)  and (DataSource.DataSet.State = dsBrowse) then DataSource.DataSet.Edit;
             FDataLink.Field.AsString:= Lines.Text;
          end;
        except
            on E : Exception do
                begin
                  ErrorMessage := ErrorMessage+E.ClassName + ' signale :<br>'+E.Message+ '<br>';
                end;
        end;
      end;
  end;
end;

constructor TYDBMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
end;

destructor TYDBMemo.Destroy;
begin
  try
  FDataLink.Free;
  except
  end;
  inherited Destroy;
end;

procedure TYDBMemo.FillFromRequest(ARequestContent: TStrings;
  var vOnClick: TYHtmlEvent; var Sender: TObject; YHTMLEXIT: string;var ErrorMessage : string);
begin
  inherited FillFromRequest(ARequestContent, vOnClick, Sender, YHTMLEXIT,ErrorMessage);
  if Self.Generate = false then exit;
  if Self.ReadOnly = true then exit;
  if ARequestContent.IndexOfName(Name) >=0 then UpdateField(ErrorMessage);
end;

function TYDBMemo.YHTML: string;
var ForceReadonly : Boolean;
begin
  Lines.Text := '';
  if not Assigned(FDataLink) then Exit;
  if not Assigned(FDataLink.Field) then Exit;
  try
    Lines.Text := v2s(FDataLink.Field.AsVariant );
  except
  end;
  ForceReadonly := fReadOnly;
  if (FDataLink.Field.ReadOnly= true) then fReadOnly := true;
  if (FDataLink.DataSet.State = dsBrowse) or
     (FDataLink.DataSet.State = dsInactive) then fReadOnly := true;
  if Assigned(FDataLink.DataSource) then
    if (FDataLink.DataSource.AutoEdit = true) and (FDataLink.DataSet.State = dsBrowse) then
    fReadOnly := ForceReadonly;

  Result:=inherited YHTML;
  fReadOnly := ForceReadonly;
end;

end.
