unit ubdd;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, YText, YBr, YButton,
  YHtmlDocument, YHtmlControl, YCombo, YMemo, YDbGrid, IBConnection, sqldb, db;

type

  { TFbdd }
  TSemCritique =  (SC_Annuaire);

  TFbdd = class(TForm)
    BtFermer: TYButton;
    DsBdd: TDataSource;
    IBConnect: TIBConnection;
    QrBdd: TSQLQuery;
    TrBdd: TSQLTransaction;
    YBr1: TYBr;
    CbTables: TYCombo;
    BtAfficher: TYButton;
    BtCreer: TYButton;
    BtDetruire: TYButton;
    BtImport: TYButton;
    BtExport: TYButton;
    YBr2: TYBr;
    CbExpType: TYCombo;
    BtReqSQL: TYButton;
    BTExeSql: TYButton;
    YBr3: TYBr;
    GrBdd: TYDbGrid;
    YHtmlDocument1: TYHtmlDocument;
    mmSql: TYMemo;
    YText1: TYText;
    procedure BtAfficherClick(Sender: TObject);
    procedure BtCreerClick(Sender: TObject);
    procedure BtDetruireClick(Sender: TObject);
    procedure BTExeSqlClick(Sender: TObject);
    procedure BtExportClick(Sender: TObject);
    procedure BtFermerClick(Sender: TObject);
    procedure BtImportClick(Sender: TObject);
    procedure BtReqSQLClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GrBddDataCommit(Sender: TObject);
    procedure GrBddDataRollback(Sender: TObject);
  private

  public

  end;

var
  Fbdd: TFbdd;

procedure SetupdDatabaseParams(Db : TIBConnection) ;
procedure SetupTransactionParams(Tr : TSQLTransaction) ;
procedure SetupQueryParams(Qr : TSQLQuery) ;

function P(ResCritique : TSemCritique;Dataset : TDataSet;User:string ) : TComponent;
procedure V(Var ObjSem : TComponent );

implementation

uses strprocs; // dbprocs;

{$R *.lfm}

procedure SetupdDatabaseParams(Db : TIBConnection) ;
begin
   Db.Connected:= false;
   Db.DatabaseName:= 'localhost:'+ FileProgramPath +
                     'bdd\ANNUAIRE.FDB';
   Db.Password:= 'masterkey';
   Db.UserName:='SYSDBA';
   Db.Connected:= true;
end;

procedure SetupTransactionParams(Tr : TSQLTransaction) ;
begin
  tr.Params.Clear;
  tr.Params.Add('isc_tpb_read_committed');
  tr.Params.Add('isc_tpb_rec_version');
  tr.Params.Add('isc_tpb_nowait');
end;

procedure SetupQueryParams(Qr : TSQLQuery) ;
begin
  Qr.Options :=[sqoKeepOpenOnCommit,sqoAutoApplyUpdates,sqoAutoCommit];
end;

procedure TFbdd.FormCreate(Sender: TObject);
begin
   SetupdDatabaseParams(IBConnect);
   SetupTransactionParams(TrBdd);
   SetupQueryParams(QrBdd);
   CbTables.Elements.AddObject('SEMAPHORES',OString.Make(
     'IDSEMAPHORE VARCHAR(100) not null primary key'
     +', IDUSER VARCHAR(6)'
     ));
   CbTables.Elements.AddObject('ANNUAIRE',OString.Make(
     'IDANU VARCHAR(3) not null primary key'
     +', NOM VARCHAR(30)'
     +', TEL VARCHAR(30)'
     +', ADRESSE VARCHAR(500)'
     +', CP VARCHAR(5)'
     +', VILLE VARCHAR(30)'
     ));
end;

procedure TFbdd.GrBddDataCommit(Sender: TObject);
begin
  TrBdd.CommitRetaining;
end;

procedure TFbdd.GrBddDataRollback(Sender: TObject);
begin
  TrBdd.RollbackRetaining;
end;

procedure PV(ResCritique : TSemCritique;Dataset : TDataSet;ObjSem : TComponent );
// Procédure P et V des sémaphores, P alloue, V Libère.
//  PV pré - libère en attendant la validation auto de la transaction à la libération de l'objet
var NomSem : string; MySql : TSQLScript; MyTrans : TSQLTransaction;
  MyCon : TIBConnection;
begin
  MyCon := TIBConnection.Create(objSem);
  MyTrans := TSQLTransaction.Create(MyCon);
  MySql := TSQLScript.Create(MyTrans);
  MyTrans.DataBase := MyCon;
  SetupdDatabaseParams(MyCon);
  SetupTransactionParams(MyTrans);
  MySql.Transaction := MyTrans;
  MyTrans.Action := caCommit;
  MyTrans.StartTransaction;
  case ResCritique of
      SC_Annuaire  :  NomSem := 'ANU ' + v2s(Dataset['IDANU']);
  end;
  MySql.Script.text := 'DELETE FROM SEMAPHORES WHERE IDSEMAPHORE = ''' + NomSem +''';';
  MySql.ExecuteScript;  //   Execute;//
end;

function P(ResCritique : TSemCritique;Dataset : TDataSet;User:string ) : TComponent;
// Procédure P et V des sémaphores, P alloue, V Libère.
// Ecrit la clé unique dans la table des sémaphores
//P fait déjà appel à V en utilisant PV() et
// la libération est effective quand le sémaphore renvoyé en résultat est libéré par free.
var NomSem : string;  MySql : TSQLScript; MyTrans : TSQLTransaction;
  MyCon : TIBConnection;
begin
  result := nil;
  if (Dataset.bof) and (Dataset.Eof) then raise Exception.Create('Fiche vide !');
  case ResCritique of
      SC_Annuaire  :  NomSem := 'ANU ' + v2s(Dataset['IDANU']);
  end;
  try
    MyCon := TIBConnection.Create(Dataset);
    MyTrans := TSQLTransaction.Create(MyCon);
    MySql := TSQLScript.Create(MyTrans);
    MyTrans.DataBase := MyCon;
    SetupdDatabaseParams(MyCon);
    SetupTransactionParams(MyTrans);
    MySql.Transaction := MyTrans;
    MyTrans.Action := caCommit;
    MyTrans.Active:= true;
    MySql.Script.text := 'INSERT INTO SEMAPHORES VALUES (''' + DoubleQuote(V2S(NomSem)) +''',''' + User +''');';
    MySql.ExecuteScript;
    MyTrans.Commit;
    Result := TComponent.Create(Dataset);
    PV(ResCritique,Dataset,result);
  except
      on e:EIBDatabaseError do
      begin
        MyTrans.RollbackRetaining;
      end;
  end;
  MySql.Free;
  MyTrans.Free;
  MyCon.Free;
end;

procedure V(Var ObjSem : TComponent );
// Procédure P et V des sémaphores, P alloue, V Libère.
// fait le free et met à nil
begin
  if ObjSem <> nil then ObjSem.Free;
  ObjSem := nil;
end;

{ TFbdd }

procedure TFbdd.BtFermerClick(Sender: TObject);
begin
    QrBdd.Active:= false;
    YHtmlDocument1.Return;
end;

procedure TFbdd.BTExeSqlClick(Sender: TObject);
begin
  QrBdd.Active:= false;
  TrBdd.Active:= true;
  TrBdd.Rollback;
  TrBdd.StartTransaction;
  IBConnect.ExecuteDirect(mmSql.Lines.Text);
  TrBdd.Commit;
  YHtmlDocument1.DisplayAlert('Traitement terminé');
end;

procedure TFbdd.BtAfficherClick(Sender: TObject);
begin
   mmSql.Lines.Text:= 'SELECT * FROM ' + CbTables.Text + ';';
   BtReqSQLClick(self);
end;

procedure TFbdd.BtCreerClick(Sender: TObject);
var posi : integer;
begin
  posi := CbTables.Elements.IndexOf(CbTables.Text);
  if posi >= 0 then
    mmSql.Lines.Text:= 'CREATE TABLE '+ CbTables.Text + ' ('+OString(CbTables.Elements.Objects[posi]).s+');';

end;

procedure TFbdd.BtDetruireClick(Sender: TObject);
begin
   mmSql.Lines.Text:= 'DROP TABLE '+ CbTables.Text + ';';
end;

procedure TFbdd.BtReqSQLClick(Sender: TObject);
begin
  GrBdd.Fields.Clear;
  QrBdd.Active:= false;
  QrBdd.SQL.Text:= mmSql.Lines.Text;
  QrBdd.Active:= true;
end;


procedure TFbdd.BtImportClick(Sender: TObject);
var  filename : String;
begin
  BtAfficherClick(self);
  filename := IBConnect.DatabaseName;
  StrToken(filename,':');
  filename :=ExtractFilePath(filename);
  filename := FileProgramPath + CbTables.Text+'';
//  TableImport(QrBdd,filename,CbExpType.Text);
  TrBdd.CommitRetaining;
  YHtmlDocument1.DisplayAlert('Import terminé');
end;

procedure TFbdd.BtExportClick(Sender: TObject);
var  filename : String;
begin
  BtAfficherClick(self);
  filename := IBConnect.DatabaseName;
  StrToken(filename,':');
  filename :=ExtractFilePath(filename);
  filename := FileProgramPath + CbTables.Text+'';
//  TableExport(QrBdd,filename,CbExpType.Text);
  YHtmlDocument1.DisplayAlert('Export terminé');
end;

end.

