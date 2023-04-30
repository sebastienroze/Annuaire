unit upersonnes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, YText, YBr, YButton,
  YHtmlDocument, YInput, YDiv, YDbGrid, sqldb, IBConnection, db, YHtmlControl,
  YClass, YLayout;

type

  { TFPersonnes }

  TFPersonnes = class(TForm)
    BtFiche: TYButton;
    BtFermer: TYButton;
    BtAjouter: TYButton;
    DsVisu: TDataSource;
    IBCon: TIBConnection;
    QrVisu: TSQLQuery;
    TrVisu: TSQLTransaction;
    YBr1: TYBr;
    YBr2: TYBr;
    BrGrille: TYBr;
    GrVisu: TYDbGrid;
    YDiv1: TYDiv;
    YHtmlDocument1: TYHtmlDocument;
    EdRecherche: TYInput;
    YLayout1: TYLayout;
    YText1: TYText;
    TxtRecherche: TYText;
    procedure BtAjouterClick(Sender: TObject);
    procedure BtFermerClick(Sender: TObject);
    procedure BtFicheClick(Sender: TObject);
    procedure EdRechercheChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GrVisuDblClick(Sender: TObject);
    procedure GrVisuHeaderClick(Sender: TObject);
    procedure GrVisuNeedFieldDefinition(var FieldTitle: string;
      CellHtmlStyle: TYHtmlStyle);
  private

  public
    procedure Recherche();
    function FieldToTitle(Field:String) : string;
  end;

var
  FPersonnes: TFPersonnes;

implementation

uses ubdd,upersonne,strprocs ;

{$R *.lfm}

{ TFPersonnes }

procedure TFPersonnes.FormCreate(Sender: TObject);
begin
  SetupdDatabaseParams(IBCon);
  SetupQueryParams(QrVisu);
  SetupTransactionParams(TrVisu);
  GrVisu.SelectedField := 'IDANU';
  GrVisuHeaderClick(self);
end;

procedure TFPersonnes.BtFermerClick(Sender: TObject);
begin
  YHtmlDocument1.Return;
end;

procedure TFPersonnes.GrVisuDblClick(Sender: TObject);
begin
  BtFicheClick(self);
end;

procedure TFPersonnes.GrVisuHeaderClick(Sender: TObject);
begin
   Recherche();
end;

procedure TFPersonnes.EdRechercheChange(Sender: TObject);
begin
  Recherche();
end;

procedure TFPersonnes.GrVisuNeedFieldDefinition(var FieldTitle: string;
  CellHtmlStyle: TYHtmlStyle);
begin
    FieldTitle := FieldToTitle(FieldTitle);
end;

function TFPersonnes.FieldToTitle(Field: String): string;
begin
  result :=  Field;
  if Field = 'IDANU' then result:= 'Code';
  if Field = 'NOM' then result:= 'Nom';
  if Field = 'ADRESSE' then result:= 'Adresse';
  if Field = 'TEL' then result:= 'Tél';
  if Field = 'CP' then result:= 'C.P.';
  if Field = 'VILLE' then result:= 'Ville';
end;

procedure TFPersonnes.Recherche();
begin
    TxtRecherche.Text := 'Recherche par ' + FieldToTitle(GrVisu.SelectedField);
    QrVisu.Active:= false;
    QrVisu.SQL.Text:= 'SELECT * FROM ANNUAIRE WHERE IDANU LIKE ''%' +
       DoubleQuote(EdRecherche.Text) + '%'' ORDER BY ' + GrVisu.SelectedField;
    QrVisu.Active:= true;
end;


procedure TFPersonnes.BtFicheClick(Sender: TObject);
begin
    YHtmlDocument1.NextForm := TFPersonne.Create(self);
    TFPersonne(YHtmlDocument1.NextForm).QrFiche.Active:= false;
    TFPersonne(YHtmlDocument1.NextForm).QrFiche.SQL.Text:= QrVisu.SQL.Text;
    TFPersonne(YHtmlDocument1.NextForm).QrFiche.Active:= true;
    TFPersonne(YHtmlDocument1.NextForm).QrFiche.Locate('IDANU',QrVisu['IDANU'],[]);
end;

procedure TFPersonnes.BtAjouterClick(Sender: TObject);
begin
  YHtmlDocument1.NextForm := TFPersonne.Create(self);
  TFPersonne(YHtmlDocument1.NextForm).QrFiche.Active:= false;
  TFPersonne(YHtmlDocument1.NextForm).QrFiche.SQL.Text:= QrVisu.SQL.Text;
  TFPersonne(YHtmlDocument1.NextForm).QrFiche.Active:= true;
  TFPersonne(YHtmlDocument1.NextForm).FenetreModeAjout := True;
  TFPersonne(YHtmlDocument1.NextForm).BtAjouterClick(self);
end;

end.

