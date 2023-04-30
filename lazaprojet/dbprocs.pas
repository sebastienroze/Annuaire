unit dbprocs;

{$mode objfpc}{$H+}

interface


uses
  Classes,db, SysUtils;

procedure TableExport(aTable : TDataset;filename,extention : string);
procedure TableImport(aTable : TDataset;filename,extention : string);

implementation

uses fpspreadsheetctrls,fpsTypes,fpsallformats,strprocs;
//https://sourceforge.net/projects/lazarus-ccr/files/FPSpreadsheet/

procedure TableExport(aTable : TDataset;filename,extention : string);
var i,WsIndex : integer;
  WbExcel : TsWorkbookSource;
begin
  WbExcel := TsWorkbookSource.Create(aTable);
  WbExcel.CreateNewWorkbook;
  for i :=0 to aTable.FieldCount -1 do
  begin
      WbExcel.Worksheet.WriteUTF8Text(0,i, aTable.Fields[i].FieldName);
  end;
  WsIndex := 1;
  aTable.First;
  while not aTable.EOF do
  begin
      for i := 0 to aTable.FieldCount -1 do
      begin
         WbExcel.Worksheet.WriteUTF8Text(WsIndex,i,v2s( aTable.Fields[i].AsVariant));
      end;
      WsIndex := WsIndex +1;
      aTable.Next;
  end;
  if extention = 'xls' then WbExcel.SaveToSpreadsheetFile(filename+'.xls',sfExcel8,true);
  if extention = 'xlsx' then WbExcel.SaveToSpreadsheetFile(filename+'.xlsx',sfExcelXML,true);
  if extention = 'ods' then WbExcel.SaveToSpreadsheetFile(filename+'.ods',sfOpenDocument,true);
  if extention = 'csv' then WbExcel.SaveToSpreadsheetFile(filename+'.csv',sfCSV,true);
  WbExcel.Free;
end;

procedure TableImport(aTable : TDataset;filename,extention : string);
var i,WsIndex,NbLigs : integer;
  LeField : TField;
  fieldname : string;
  WbExcel : TsWorkbookSource;
begin
  WbExcel := TsWorkbookSource.Create(aTable);
//  filename := filename + '.'+extention;
  if extention = 'xls' then WbExcel.LoadFromSpreadsheetFile(filename+'.xls',sfExcel8,-1);
  if extention = 'xlsx' then WbExcel.LoadFromSpreadsheetFile(filename+'.xlsx',sfExcelXML,-1);
  if extention = 'ods' then WbExcel.LoadFromSpreadsheetFile(filename+'.ods',sfOpenDocument,-1);
  if extention = 'csv' then WbExcel.LoadFromSpreadsheetFile(filename+'.csv',sfCSV,-1);
  NbLigs := WbExcel.Worksheet.GetCellCountInCol(0)-1 ;
  for WsIndex:= 1 to NbLigs do
  begin
      aTable.Append;
      for i := 0 To WbExcel.Worksheet.GetCellCountInRow(0)-1 do
      begin
        fieldname :=  WbExcel.Worksheet.ReadAsUTF8Text(0,i);
        if (fieldname <> '') then
        begin
          LeField := aTable.FieldByName(fieldname);
          try
          LeField.AsVariant:= ( WbExcel.Worksheet.ReadAsUTF8Text(WsIndex,i));
          except
          end;
        end;
      end;
      aTable.Post;
  end;
end;
end.

