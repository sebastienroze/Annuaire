unit umenu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, YText, YBr, YButton,
  YImage, YDiv, YLayout, YHtmlControl, YHtmlDocument;

type

  { TFMenu }

  TFMenu = class(TForm)
    BtBdd: TYButton;
    BtPersonnes: TYButton;
    YBr1: TYBr;
    BtFermer: TYButton;
    YBr2: TYBr;
    YDiv1: TYDiv;
    YHtmlDocument1: TYHtmlDocument;
    YImage1: TYImage;
    YLayout1: TYLayout;
    YText1: TYText;
    procedure BtBddClick(Sender: TObject);
    procedure BtFermerClick(Sender: TObject);
    procedure BtPersonnesClick(Sender: TObject);
  private

  public

  end;

var
  FMenu: TFMenu;

implementation

uses ubdd,upersonnes;

{$R *.lfm}

{ TFMenu }

procedure TFMenu.BtFermerClick(Sender: TObject);
begin
  YHtmlDocument1.Return;
end;

procedure TFMenu.BtPersonnesClick(Sender: TObject);
begin
  YHtmlDocument1.NextForm := TFPersonnes.Create(self);
end;

procedure TFMenu.BtBddClick(Sender: TObject);
begin
  YHtmlDocument1.NextForm := TFbdd.Create(self);
end;

end.

