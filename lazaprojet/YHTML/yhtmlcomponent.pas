unit YHtmlComponent;

{$mode objfpc}{$H+}

interface

uses YHtmlControl,
  ExtCtrls,Classes,controls,yclass;



   { TYHtmlComponent }




procedure Debug(DebugMessage : string);

implementation

{ TYHtmlComponent }


uses YView,forms,Graphics,strprocs,YHtmlDocument;   //    SysUtils,

procedure Debug(DebugMessage : string);
begin
  DebugMessage := DebugMessage;
end;

{ TYCustomHtmlComponent }


{ TYCustomHtmlControl }






end.

