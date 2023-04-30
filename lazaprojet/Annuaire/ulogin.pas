unit ulogin;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, YDiv, YText, YInput,
  YBr, YButton, YHtmlDocument, YHtmlControl;

type

  { TFLogin }

  TFLogin = class(TForm)
    YBr1: TYBr;
    YBr2: TYBr;
    YBr3: TYBr;
    BtOk: TYButton;
    YDiv1: TYDiv;
    YDiv2: TYDiv;
    EdLogin: TYInput;
    EdMdp: TYInput;
    YHtmlDocument1: TYHtmlDocument;
    YText1: TYText;
    YText2: TYText;
    YText3: TYText;
    procedure BtOkClick(Sender: TObject);
    procedure YHtmlDocument1GenerateHTML(Sender: TObject);
  private

  public

  end;

var
  FLogin: TFLogin;

implementation

uses umenu;

{$R *.lfm}

{ TFLogin }

procedure TFLogin.YHtmlDocument1GenerateHTML(Sender: TObject);
begin
  YHtmlDocument1.UserName := '';
end;

procedure TFLogin.BtOkClick(Sender: TObject);
begin
   YHtmlDocument1.UserName := EdLogin.Text;
   if YHtmlDocument1.UserName <> '' then
   YHtmlDocument1.NextForm := TFMenu.Create(self);
end;

end.

