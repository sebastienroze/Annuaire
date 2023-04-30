unit upersonne;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, YText, YBr, YButton,
  YHtmlDocument, IBConnection, sqldb, db, YHtmlControl, YDBInput;

type

  { TFPersonne }

  TFPersonne = class(TForm)
    BtAjouter: TYButton;
    BtModifier: TYButton;
    BtPrecedant: TYButton;
    BtFermer: TYButton;
    BtOk: TYButton;
    BTAnnuler: TYButton;
    BtSupprimer: TYButton;
    BtSuivant: TYButton;
    DsFiche: TDataSource;
    IBCon: TIBConnection;
    QrFiche: TSQLQuery;
    TrFiche: TSQLTransaction;
    YBr1: TYBr;
    YBr2: TYBr;
    YBr3: TYBr;
    YBr4: TYBr;
    EdCode: TYDBInput;
    YBr5: TYBr;
    YBr6: TYBr;
    YBr8: TYBr;
    YDBInput2: TYDBInput;
    YDBInput3: TYDBInput;
    YDBInput4: TYDBInput;
    YDBInput5: TYDBInput;
    YDBInput6: TYDBInput;
    YHtmlDocument1: TYHtmlDocument;
    YText1: TYText;
    YText2: TYText;
    YText3: TYText;
    YText4: TYText;
    YText5: TYText;
    YText6: TYText;
    YText7: TYText;
    procedure BtAjouterClick(Sender: TObject);
    procedure BTAnnulerClick(Sender: TObject);
    procedure BtFermerClick(Sender: TObject);
    procedure BtModifierClick(Sender: TObject);
    procedure BtOkClick(Sender: TObject);
    procedure BtPrecedantClick(Sender: TObject);
    procedure BtSuivantClick(Sender: TObject);
    procedure BtSupprimerClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure YHtmlDocument1GenerateHTML(Sender: TObject);
  private
    Semaphore : TComponent;
  public
    FenetreModeAjout: boolean;
    procedure ModeConsultation;
    procedure ModeModification;
  end;

var
  FPersonne: TFPersonne;

implementation

uses ubdd,strprocs;

{$R *.lfm}

{ TFPersonne }

procedure TFPersonne.FormCreate(Sender: TObject);
begin
  Semaphore := nil;
  SetupdDatabaseParams(IBCon);
  SetupQueryParams(QrFiche);
  SetupTransactionParams(TrFiche);
  FenetreModeAjout := false;
  ModeConsultation;
end;

procedure TFPersonne.YHtmlDocument1GenerateHTML(Sender: TObject);
begin
    BtSupprimer.Confirmation := 'Supprimer la personne ' + v2s(QrFiche['IDANU']) + ' ' +v2s(QrFiche['NOM']) + ' ?';
end;

procedure TFPersonne.BtPrecedantClick(Sender: TObject);
begin
  QrFiche.Prior;
  if (QrFiche.BOF  = true) then BtPrecedant.HtmlStyle.Hidden:= true;
  BtSuivant.HtmlStyle.Hidden:= false;
end;

procedure TFPersonne.BtModifierClick(Sender: TObject);
var IDANU : string;
begin
  Semaphore := P(SC_Annuaire,QrFiche,YHtmlDocument1.GetUsername);
  if Semaphore <> nil then
  try
    IDANU := V2S(QrFiche['IDANU']);
    QrFiche.Refresh;
    QrFiche.Locate('IDANU',IDANU,[]);
    if YHtmlDocument1.CurrentFocus = BtModifier.YInnerName then YHtmlDocument1.CurrentFocus := EdCode.YInnerName;
    ModeModification;
    QrFiche.Edit;
  except
    on E:Exception do
    begin
      YHtmlDocument1.DisplayAlert(PChar(e.message));
      ModeConsultation;
    end;
  end
  else YHtmlDocument1.DisplayAlert('Cet engergistrement est verrouillé !');
end;

procedure TFPersonne.BtOkClick(Sender: TObject);
begin
   Try
      QrFiche.Post;
      TrFiche.CommitRetaining;
      ModeConsultation;
   except
     YHtmlDocument1.DisplayAlert('Ce code est déjà utilisé');
     YHtmlDocument1.CurrentFocus :=  EdCode.YInnerName;
     QrFiche.Edit;
   end;
end;

procedure TFPersonne.BtAjouterClick(Sender: TObject);
begin
  EdCode.ReadOnly:= false;
  QrFiche.Append;
  ModeModification;
  YHtmlDocument1.CurrentFocus := EdCode.YInnerName;
end;

procedure TFPersonne.BTAnnulerClick(Sender: TObject);
begin
   QrFiche.Cancel;
   TrFiche.RollbackRetaining;
   ModeConsultation;
   if FenetreModeAjout = true then BtFermerClick(self);
end;

procedure TFPersonne.BtFermerClick(Sender: TObject);
begin
  YHtmlDocument1.Return;
end;

procedure TFPersonne.BtSuivantClick(Sender: TObject);
begin
  QrFiche.Next;
  if (QrFiche.EOF  = true) then BtSuivant.HtmlStyle.Hidden:= true;
  BtPrecedant.HtmlStyle.Hidden:= false;
end;

procedure TFPersonne.BtSupprimerClick(Sender: TObject);
begin
  Semaphore := P(SC_Annuaire,QrFiche,YHtmlDocument1.GetUsername);
  if Semaphore <> nil then
  begin
    QrFiche.Delete;
    TrFiche.CommitRetaining;
  end;
end;

procedure TFPersonne.ModeConsultation;
begin
  EdCode.ReadOnly:= true;
  if Semaphore<> nil then Semaphore.Free;
  BTAnnuler.Generate:= false;
  BtOk.Generate:= false;
  BtAjouter.Generate:= true;
  BtModifier.Generate:= true;
  BtSupprimer.Generate:= true;
  BtFermer.Generate:= true;
  BtPrecedant.Generate:= true;
  BtSuivant.Generate:= true;
end;

procedure TFPersonne.ModeModification;
begin
  BTAnnuler.Generate:= true;
  BtOk.Generate:= true;
  BtAjouter.Generate:= false;
  BtModifier.Generate:= false;
  BtSupprimer.Generate:= false;
  BtFermer.Generate:= false;
  BtPrecedant.Generate:= false;
  BtSuivant.Generate:= false;
end;

end.

