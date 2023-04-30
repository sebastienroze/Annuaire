unit userveur;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, YServer;

type

  { TFServeur }

  TFServeur = class(TForm)
    btLocalhost: TButton;
    BtIp: TButton;
    YServer1: TYServer;
    procedure BtIpClick(Sender: TObject);
    procedure btLocalhostClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure YServer1FormRequest(Sender: TObject; var aNewForm: TForm;
      FormName: string);
  private

  public

  end;

var
  FServeur: TFServeur;

implementation

uses sysprocs,lclintf,ulogin;

{$R *.lfm}

{ TFServeur }

procedure TFServeur.FormCreate(Sender: TObject);
begin
  BtIp.Caption := 'Ouvrir ' + GetAdresseIp();
end;

procedure TFServeur.btLocalhostClick(Sender: TObject);
begin
  OpenURL('http://localhost');
end;

procedure TFServeur.BtIpClick(Sender: TObject);
begin
   OpenURL('http://'+GetAdresseIp());
end;

procedure TFServeur.YServer1FormRequest(Sender: TObject; var aNewForm: TForm;
  FormName: string);
begin
   aNewForm := TFLogin.Create(Self);
end;

end.

