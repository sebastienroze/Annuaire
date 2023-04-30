unit strprocs;


{$mode objfpc}{$H+}

interface

uses Classes;

const
  CR = #13;
  LF = #10;
  TAB = #9;
  CRLF = CR + LF;


function StrToken(var Chaine: string; separateur: string): string;
function strRight(const Chaine: string; Taille: integer): string;
function strLeft(const Chaine: string; Taille: integer): string;
function StrTrim(Chaine: string): string;
function StrTrimL(s: string): string;
function StrTrimR(s: string): string;
function StrReplace(Chaine, Cherche, Remplace: string): string;
function ValInt(Chaine: string): integer;
function ValFlt(Chaine: string): double;
function StrTokenNumAlpha(var Chaine: string): string;
function FileProgramPath: string;
function StrAddSlash(s: string): string;
function StrDelSlash(s: string): string;
function StrPad(Chaine, PadChar: string; Taille: integer): string;
function StrComplete(Chaine, ComplChar: string; Taille: integer): string;
function V2S(V: variant): string;
function V2Flt(V: variant): double;
function v2Bool(V: variant): boolean;
function V2SDateShort(v: variant): string;
function V2SDate(v: variant): string;
function V2STime(v: variant): string;
function V2Sq(V: variant): string;
function StrRemplace(Chaine, Cherche, Remplace: string): string;
//StringReplace(Chaine,Cherche,Remplace,rfReplaceAll);
function DoubleQuote(Chaine : string) : string;
function StrEmpty(Chaine: string): boolean;
function ExtractStrDigits(Chaine: string): string;
function isNumeric(chaine: string): boolean;
function FmtDate(sdate: string): string;
function Datefmt(Editdate: string): string;
function Timefmt(EditTime: string): string;
function Timefmt6(EditTime: string): string;
function Directory(FileMask: string): TStringList;
function DateYear(UneDate: TDateTime): integer;
function DateMonth(UneDate: TDateTime): integer;
function DateDay(UneDate: TDateTime): integer;



type
  OString = class(TObject)
    s: string;
    constructor Make(str: string);
  end;


implementation

uses
  SysUtils,variants;



function Directory(FileMask: string): TStringList;
var
  sr: TSearchRec;
  FileAttrs: integer;
begin
  Result := TStringList.Create;
  //  FileAttrs := faAnyFile;
  FileAttrs := faDirectory;//+faHidden  ;
  if SysUtils.FindFirst(FileMask, FileAttrs, sr) = 0 then
  begin
    Result.add(sr.Name);
    while SysUtils.FindNext(sr) = 0 do
    begin
      Result.add(sr.Name);
    end;
  end;
  SysUtils.FindClose(sr);
end;

function isNumeric(chaine: string): boolean;
var
  ch: string;
  i: integer;
begin
  Result := True;
  for i := 0 to Length(chaine) do
  begin
    ch := Copy(chaine, i, 1);
    if not (('0' <= ch) and (ch <= '9') or (ch = '.')) then
      Result := False;
  end;
end;

function ExtractStrDigits(Chaine: string): string;
var
  i: integer;
  car: string;
begin
  Result := '';
  for i := 1 to Length(Chaine) do
  begin
    car := copy(Chaine, i, 1);
    if (car >= '0') and (car <= '9') then
      Result := Result + car;
  end;
end;

function StrEmpty(Chaine: string): boolean;
  // Teste si une chaine est vide ou ne contient que des espaces ou retour chariot
var
  i: integer;
begin
  i := 1;
  Result := True;
  while (Result) and (i <= Length(Chaine)) do
  begin
    if (Chaine[i] <> ' ') and (Chaine[i] <> CR) and (Chaine[i] <> LF) then
    begin
      Result := False;
    end;
    i := i + 1;
  end;
end;

function DoubleQuote(Chaine: string) : string;
var i : integer;
  ch : string;
begin
  result := '';
  for i := 1 to Length(Chaine) do
  begin
    ch := Copy(Chaine,i,1);
    if ch = '''' then ch := '''''';
    Result := Result+ch;
  end;
end;

function StrRemplace(Chaine, Cherche, Remplace: string): string;
  // Recherche et remplace dans une chaine de caratères
var
  i: integer;
  LenCherche: integer;
  LenChaine: integer;
  LastFind: integer;
begin
  LenCherche := Length(Cherche);
  LenChaine := Length(Chaine);
  Result := '';
  if LenCherche > 0 then
  begin
    i := 1;
    LastFind := 1;
    while i - 1 <= (LenChaine - LenCherche) do
    begin
      if Copy(Chaine, i, LenCherche) = Cherche then
      begin
        Result := Result + Copy(Chaine, LastFind, i - LastFind) + Remplace;
        i := i + LenCherche;
        LastFind := i;
      end
      else
      begin
        i := i + 1;
      end;
    end;
    Result := Result + Copy(Chaine, LastFind, LenChaine);
  end
  else
  begin
    Result := Chaine;
  end;
end;

function V2Flt(V: variant): double;
begin
  Result := 0;
  if v <> Null then
    try
      Result := v;
    except
    end;
end;

function V2S(V: variant): string;
  // converti le variant en chaine de caracère
begin
  Result := '';
  if v <> Null then
    try
      Result := VarToStr(v);
    except
    end;
end;

function V2Sq(V: variant): string;
begin
    result := DoubleQuote(V2S(V));
end;

function V2SDate(v: variant): string;
begin
  Result := '';
  if v <> Null then
    try
      Result := DateToStr(v);
    except
    end;
end;

function V2SDateShort(v: variant): string;
begin
  Result := '';
  if v <> Null then
    try
      Result := FormatDateTime('dd/mm/yy', v);
    except
    end;
end;

function V2STime(v: variant): string;
begin
  Result := '';
  if v <> Null then
    try
      Result := TimeToStr(v);
    except
    end;
end;

function v2Bool(V: variant): boolean;
begin
  Result := False;
  if v <> Null then
    try
      if valint(V) = -1 then
        Result := True
      else
        Result := v;
    except
    end;
end;

function StrPad(Chaine, PadChar: string; Taille: integer): string;
{ Fait débuter la chaine passée en parametre par le caractère PadCar pour atteindre une certaine taille
Ex StrPad('12','0',4) renvoie 0012   , deux zéros sont ajoutés pour un format en quatre chiffre
}
begin
  if PadChar = '' then
    exit;
  Result := Chaine;
  while Length(Result) < Taille do
  begin
    Result := PadChar + Result;
  end;
end;

function StrComplete(Chaine, ComplChar: string; Taille: integer): string;
{ Fait terminer la chaine passée en parametre par le caractère PadCar pour atteindre une certaine taille
Ex StrComplete('12','0',4) renvoie 1200   , deux zéros sont ajoutés en fin pour un format en quatre chiffre
}
begin
  Result := Chaine;
  while Length(Result) < Taille do
  begin
    Result := Result + ComplChar;
  end;
end;
function StrAddSlash(s: string): string;
  {rajoute un slash en fin de chaine si il manque}
begin
  if Copy(s, Length(s), 1) = '\' then
    Result := s
  else
    Result := s + '\';
end;

function StrDelSlash(s: string): string;
  {rajoute un slash en fin de chaine si il manque}
begin
  if Copy(s, Length(s), 1) = '\' then
    Result := Copy(s, 1, Length(s) - 1)
  else
    Result := s;
end;

function FileProgramPath: string;
  // Renvoie le chemin de l'exécutable en cours
begin
  Result := StrAddSlash(ExtractFilePath(ParamStr(0)));
end;

function StrToken(var Chaine: string; separateur: string): string;
{
Coupe et renvoie la première partie de la chaine jusqu'au séparateur
Pour les connaisseur du Lisp :
Renvoie le car de la liste matérialisée par 'Chaine' dont les atomes sont séparés de séparateur
La liste deviens alors son cdr

Exemple
Chaine := 'a,b,c,d'
Resultat  := StrToken(Chaine,',')
Résultat vaut 'a'
Chaine vaut 'b,c,d'
}
var
  Position: integer;
begin
  Position := Pos(separateur, Chaine);
  if Position > 0 then
  begin
    Result := Strleft(Chaine, Position - 1);
    Chaine := StrRight(Chaine, Length(Chaine) - Length(separateur) - Position + 1);
  end
  else
  begin
    Result := Chaine;
    Chaine := '';
  end;
end;

function StrTokenNumAlpha(var Chaine: string): string;
{Coupe et renvoie la première partie de la chaine numérique / Alpha
Exemple
  StrTokenNumAlpha('012AZE15') renvoie '012' et chaine deviens 'AZE15'
  StrTokenNumAlpha('AZE15Az') renvoie 'AZE' et chaine deviens '15Az'}
var
  Premier, Numeric, bStop: boolean;
  Carac: string;
begin
  Result := '';
  bStop := False;
  Numeric := False;
  Premier := True;
  while (Chaine <> '') and (bStop = False) do
  begin
    Carac := Copy(Chaine, 1, 1);
    if ((Carac >= '0') and (Carac <= '9')) or (Carac='-') then
    begin
      if Premier = True then
        Numeric := True
      else
      begin
        if Numeric = False then
          bStop := True;
      end;
    end
    else
    begin
      if Premier = False then
      begin
        if Numeric = True then
          bStop := True;
      end;
    end;
    Premier := False;
    if bStop = False then
    begin
      Result := Result + carac;
      System.Delete(Chaine, 1, 1);
    end;
  end;
end;

function ValInt(Chaine: string): integer;
  {Renvoie la valeur entiere d'une chaine ou zéro si le résultat n'est pas valide}
begin
  if Chaine = '' then
    Chaine := '0'; // trop d'exeption
  try
    Result := StrToInt(Chaine);
  except
    Result := 0;
  end;
end;

function ValFlt(Chaine: string): double;
begin
  if Chaine = '' then
    Chaine := '0'; // trop d'exeption
  try
    Result := StrToFloat(Chaine);
  except
    Result := 0;
  end;
end;

function StrTrimR(s: string): string;
begin
  while copy(s, Length(s), 1) = ' ' do
  begin
    System.Delete(s, Length(s), 1);
  end;
  Result := s;
end;

function StrTrimL(s: string): string;
begin
  while copy(s, 1, 1) = ' ' do
  begin
    System.Delete(s, 1, 1);
  end;
  Result := s;
end;

function StrTrim(Chaine: string): string;
begin
  Result := StrTrimL(StrTrimR(chaine));
end;

function strLeft(const Chaine: string; Taille: integer): string;
  // Renvoie la partie gauche de la chaine de caractère
begin
  Result := Copy(Chaine, 1, Taille);
end;

function strRight(const Chaine: string; Taille: integer): string;
  // Renvoie la partie droite de la chaine de caractère
begin
  if Taille >= Length(Chaine) then
    Result := Chaine
  else
    Result := Copy(Chaine, Length(Chaine) - Taille + 1, Taille);
end;

function StrReplace(Chaine, Cherche, Remplace: string): string;
  // Recherche et remplace dans une chaine de caratères
var
  i: integer;
  LenCherche: integer;
  LenChaine: integer;
  LastFind: integer;
begin
  LenCherche := Length(Cherche);
  LenChaine := Length(Chaine);
  Result := '';
  if LenCherche > 0 then
  begin
    i := 1;
    LastFind := 1;
    while i - 1 <= (LenChaine - LenCherche) do
    begin
      if Copy(Chaine, i, LenCherche) = Cherche then
      begin
        Result := Result + Copy(Chaine, LastFind, i - LastFind) + Remplace;
        i := i + LenCherche;
        LastFind := i;
      end
      else
      begin
        i := i + 1;
      end;
    end;
    Result := Result + Copy(Chaine, LastFind, LenChaine);
  end
  else
  begin
    Result := Chaine;
  end;
end;

function Datefmt(Editdate: string): string;
  // ex : Datefmt('25/04/2007') =>  20070425
var
  jj, mm, aaaa: string;
begin
  jj := Strtoken(Editdate, '/');
  mm := StrTrim(Strtoken(Editdate, '/'));
  aaaa := StrTrim(Strtoken(Editdate, '/'));
  if Length(jj) = 6 then
  begin
    aaaa := Copy(jj, 5, 2);
    mm := Copy(jj, 3, 2);
    jj := Copy(jj, 1, 2);
  end;
  if Length(jj) = 8 then
  begin
    aaaa := Copy(jj, 5, 4);
    mm := Copy(jj, 3, 2);
    jj := Copy(jj, 1, 2);
  end;
  if StrEmpty(aaaa) then
    aaaa := IntToStr(dateYear(date));
  if StrEmpty(mm) then
    mm := IntToStr(dateMonth(date));
  if StrEmpty(jj) then
    Result := ''
  else
  begin
    if length(aaaa) < 4 then
    begin
      aaaa := '2' + StrPad(aaaa, '0', 3);
    end;
    aaaa := IntToStr(valint(aaaa));
    mm := IntToStr(valint(mm));
    jj := IntToStr(valint(jj));
    mm := StrPad(mm, '0', 2);
    jj := StrPad(jj, '0', 2);
    Result := aaaa + mm + jj;
  end;
end;

function Timefmt(EditTime: string): string;
var
  i, h, m: integer;
  sep: integer;
begin
  h := 0;
  m := 0;
  sep := 0;
  if valint(EditTime) >= 100 then
    Result := StrPad(EditTime, '0', 4)
  else
  begin
    for i := 1 to Length(EditTime) do
    begin
      if (EditTime[i] >= '0') and (EditTime[i] <= '9') then
      begin
        if (sep = 1) or (sep = 2) then
        begin
          sep := sep + 1;
          m := m * 10 + ValInt(EditTime[i]);
        end;
        if (sep = 0) then
          h := h * 10 + ValInt(EditTime[i]);
      end
      else
      begin
        sep := sep + 1;
      end;
    end;
    if h + m > 0 then
    begin
      Result := StrPad(IntToStr(h), '0', 2) + StrPad(IntToStr(m), '0', 2);
    end
    else
      Result := '';
  end;
end;

function Timefmt6(EditTime: string): string;
var
  i, h, m: integer;
  sep: integer;
begin
  h := 0;
  m := 0;
  sep := 0;
  for i := 1 to Length(EditTime) do
  begin
    if (EditTime[i] >= '0') and (EditTime[i] <= '9') then
    begin
      if (sep = 1) or (sep = 2) then
      begin
        m := m * 10 + ValInt(EditTime[i]);
      end;
      if (sep = 0) then
        h := h * 10 + ValInt(EditTime[i]);
    end
    else
    begin
      sep := sep + 1;
    end;
  end;
  if h + m > 0 then
    Result := StrPad(IntToStr(h), '0', 2) + StrPad(IntToStr(m), '0', 4)
  else
    Result := '';
end;

function FmtDate(sdate: string): string;
  // AAAAMMJJ => JJ/MM/AAAA
begin
  if (sdate = '0') or (sdate = '') then
    Result := ''
  else
    Result := copy(sdate, 7, 2) + '/' + copy(sdate, 5, 2) + '/' + copy(sdate, 1, 4);
end;

function DateYear(UneDate: TDateTime): integer;
  {Renvoie l'année de la date passée en parametre}
var
  y, m, d: word;
begin
  DecodeDate(UneDate, y, m, d);
  Result := y;
end;

function DateMonth(UneDate: TDateTime): integer;
  {Renvoie le mois  de la date passée en parametre}
var
  y, m, d: word;
begin
  DecodeDate(UneDate, y, m, d);
  Result := m;
end;

function DateDay(UneDate: TDateTime): integer;
  {Renvoie le jour de la date passée en parametre}
var
  y, m, d: word;
begin
  DecodeDate(UneDate, y, m, d);
  Result := d;
end;

{ OString }

constructor OString.Make(str: string);
begin
  inherited Create;
  Self.S := str;
end;


end.

