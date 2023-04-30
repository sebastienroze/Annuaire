unit YDbGrid;

{$mode objfpc}{$H+}

interface

uses YHtmlControl, YDiv, YScrollbar, YButton, YClass, DB,
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;

type

  TOnNeedFieldDefinitionEvent = procedure(var FieldTitle: string;
    {%H-}CellHtmlStyle: TYHtmlStyle) of object;

  TOnNeedCellDefinitionEvent = procedure(var FieldName: string;
    {%H-}CellHtmlStyle: TYHtmlStyle) of object;

  { TYDbGrid }

  TYDbGrid = class(TYCustomView)
  private
    fDataSource: TDataSource;
    fDisplayRowCount: integer;
    fDivGrille: TYDiv;
    fScrollbar: TYScrollbar;
    fBtAdd,fBtModif, fBtDel: TYButton;
    fBtOK, fBtCancel: TYButton;
    fReadOnly: boolean;
    fFields: TStrings;
    fOnNeedFieldDefinition: TOnNeedFieldDefinitionEvent;
    fOnNeedCellDefinition: TOnNeedCellDefinitionEvent;
    fOnHeaderClick: TYHtmlEvent;
    fOnDataCommit: TYHtmlEvent;
    fOnDataRollback: TYHtmlEvent;
    fOnDblClick: TYHtmlEvent;
    fClassHeader: TYClass;
    fClassLine: TYClass;
    fClassSelectedLine: TYClass;
    fAutoExtand: boolean;
    fUseYView: boolean;
    fEditMode: boolean;
    function GetfFields: TStrings;
    function GetHtmlStyleHeader: TYHtmlStyle;
    function GetHtmlStyleLine: TYHtmlStyle;
    function GetHtmlStyleSelectedLine: TYHtmlStyle;
    procedure SetfFields(AValue: TStrings);
    procedure SetHtmlStyleHeader(AValue: TYHtmlStyle);
    procedure SetHtmlStyleLine(AValue: TYHtmlStyle);
    procedure SetHtmlStyleSelectedLine(AValue: TYHtmlStyle);
    procedure SetOnHeaderClick(AValue: TYHtmlEvent);
    procedure SetText(AValue: string);
    function ScriptInnerFocusEvent(InnerFocusName, sparent: string): string;
    function ScriptInnerFocus(InnerFocusName: string): string;

  protected
//    mode_modif: boolean;
    mode_ajout: boolean;
    procedure Loaded; override;
  public
    AsView: boolean;
    SelectedField: string;
    procedure ClickModif(Sender: TObject);
    procedure ClickOk(Sender: TObject);
    procedure ClickCancel(Sender: TObject);
    procedure ClickAdd(Sender: TObject);
    procedure ClickDel(Sender: TObject);
    procedure scrollbottom(Sender: TObject);
    procedure scrollup(Sender: TObject);
    procedure scrolldown(Sender: TObject);
    procedure scrolltop(Sender: TObject);
    procedure scrollpgup(Sender: TObject);
    procedure scrollpgdown(Sender: TObject);
    procedure scrollcursor(position: string);

    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure Paint; override;
    function YHTML: string; override;
    procedure AddCss(Lines: TStrings); override;
    function Yscript: string; override;
    function YScript_browserResize: string; override;
    function Yscript_mousemove: string; override;
    function Yscript_touchmove: string; override;
    function Yscript_mouseup: string; override;
    function Yscript_touchend: string; override;
    function Yscript_keydown: string; override;
    procedure FillFromRequest(ARequestContent: TStrings; var vOnClick: TYHtmlEvent;
      var Sender: TObject; YHTMLEXIT: string;var ErrorMessage : string); override;
  published
    property HtmlStyleHeader: TYHtmlStyle read GetHtmlStyleHeader
      write SetHtmlStyleHeader;
    property HtmlStyleLine: TYHtmlStyle read GetHtmlStyleLine write SetHtmlStyleLine;
    property HtmlStyleSelectedLine: TYHtmlStyle
      read GetHtmlStyleSelectedLine write SetHtmlStyleSelectedLine;
    property OnNeedFieldDefinition: TOnNeedFieldDefinitionEvent
      read fOnNeedFieldDefinition write fOnNeedFieldDefinition;
    property OnNeedCellDefinition: TOnNeedCellDefinitionEvent
      read fOnNeedCellDefinition write fOnNeedCellDefinition;

    property OnHeaderClick: TYHtmlEvent read fOnHeaderClick write fOnHeaderClick;
    property OnDblClick: TYHtmlEvent read fOnDblClick write fOnDblClick;
    property OnDataCommit: TYHtmlEvent read fOnDataCommit write fOnDataCommit;
    property OnDataRollback: TYHtmlEvent read fOnDataRollback write fOnDataRollback;
    property DataSource: TDataSource read fDataSource write fDataSource;
    property DisplayRowCount: integer read fDisplayRowCount write fDisplayRowCount;
    property AutoExtand: boolean read fAutoExtand write fAutoExtand;
    property Fields: TStrings read GetfFields write SetfFields;
    property ReadOnly: boolean read fReadOnly write fReadOnly;
    property UseYView: boolean read fUseYView write fUseYView;
    property EditMode: boolean read fEditMode write fEditMode;
    property TabStop;
  end;


procedure Register;

implementation

uses strprocs, YLayout, strutils;

procedure Register;
begin
  {$I ydbgrid_icon.lrs}
  RegisterComponents('YHTML', [TYDbGrid]);
end;

{ TYDbGrid }


constructor TYDbGrid.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  fUseYView := True;
  AsView := True;
  UseFocusKeys := True;
  FocusEnabled := True;
  fAutoExtand := False;
  fFields := TStringList.Create;
  SelectedField := '';
  fClassHeader := TYClass.Create(self);
  NoticeBrowserResize := True;
  if csDesigning in ComponentState then
  begin
    ;
{    fClassHeader.HtmlStyle.border_top := '1px solid #EEEEEE';
    fClassHeader.HtmlStyle.border_left := '1px solid #EEEEEE';
    fClassHeader.HtmlStyle.border_right := '1px solid #AAAAAA';
    fClassHeader.HtmlStyle.border_bottom := '1px solid #AAAAAA';    }
    //    fClassHeader.HtmlStyle.position_width:= '100%';
    //    fClassHeader.HtmlStyle.position_height:= '100%';
  end;

  fClassLine := TYClass.Create(self);
  fClassLine.HtmlStyle.background_color := 'white';
  fClassSelectedLine := TYClass.Create(self);
  fClassSelectedLine.HtmlStyle.background_color := '#0080FF';
  fClassSelectedLine.HtmlStyle.font_color := 'white';
  //  fClassSelectedLine.HtmlStyle.custom_style:= 'outline:2px dashed blue;'; // inherit;'; //
  if (csDesigning in ComponentState) = False then
  begin
    fDivGrille := TYDiv.Create(self);
    fDivGrille.Parent := self;
    fDivGrille.TabOrder := 0;
    fDivGrille.HtmlStyle.custom_style := 'margin-left:20px;margin-top:0px;';
    fBtAdd := TYButton.Create(self);
    fBtAdd.Text := 'Ajouter';
    fBtAdd.OnClick := @ClickAdd;
    fBtModif := TYButton.Create(self);
    fBtModif.Text := 'Modifier';
    fBtModif.OnClick := @ClickModif;
    fBtOK := TYButton.Create(self);
    fBtOK.Text := 'OK';
    //    fBtOK.OnClick:= @ClickOk;
    fBtCancel := TYButton.Create(self);
    fBtCancel.Text := 'Annuler';
    fBtCancel.OnClick := @ClickCancel;
    fBtDel := TYButton.Create(self);
    fBtDel.Text := 'Supprimer';
    fBtDel.OnClick := @ClickDel;
//    mode_modif := False;
//    mode_ajout := False;
  end;

  BrBefore := True;
  BrAfter := True;
  DisplayRowCount := 10;
  fReadOnly := True;
end;

procedure TYDbGrid.Loaded;
begin
  inherited Loaded;
  if (csDesigning in ComponentState) = False then
  begin
    fDivGrille.Name := 'DivGrille_' + Self.Name;
    fBtAdd.Name := Self.Name + '_Add';
    fBtModif.Name := Self.Name + '_Mod';
    fBtDel.Name := Self.Name + '_Del';
    fBtOK.Name := Self.Name + '_OK';
    fBtCancel.Name := Self.Name + '_Cancel';
    fScrollbar := TYScrollbar.Create(self);
    //fScrollbar.TargetView := self.FindViewParent;
    fScrollbar.Parent := self;//.FindViewParent;
    fScrollbar.Name := 'scrollbar_' + Self.Name;
    fScrollbar.Generate := False;
    fScrollbar.TabOrder := 0;
    fScrollbar.Layout := TYLayout.Create(self.FindWinParent);//.FindViewParent);
    fScrollbar.Layout.Generate := True;
    //    fScrollbar.Parent := self.FindWinParent;
    //    fScrollbar.Layout.ParentControl := self.FindViewParent;
    fScrollbar.Layout.AlignHeight := Self.fDivGrille;
    fScrollbar.Layout.ScriptsPriority := YspBeforeNormal;
    fScrollbar.Vertical := True;
    fScrollbar.HtmlStyle.position_width := '18px';
    fScrollbar.HtmlStyle.position := TYpAbsolute;
    fScrollbar.InternalButtonPosition := 'position:absolute;widht:100%;';
    fScrollbar.HtmlStyle.margin := '3px 0px 0px 2px;';
    //    TYLayout(fScrollbar.Layout).Margin := 3;
    if UseYView = True then
    begin
      fScrollbar.TargetView := self;
      fScrollbar.Layout.AlignTop := Self;
      fScrollbar.Layout.AlignLeft := Self;
    end;
    TYLayout(fScrollbar.Layout).Scale := -8;
    fClassHeader.Name := 'Header_' + Self.Name;
    fClassHeader.ElementAffected := 'th';
    fClassLine.Name := 'dbgridline_' + Self.Name;
    fClassSelectedLine.Name := 'dbgridline_selected' + Self.Name;
  end;
end;

destructor TYDbGrid.Destroy;
begin
  fFields.Free;
  inherited Destroy;
end;

procedure TYDbGrid.SetText(AValue: string);
var
  posiLig, Offsetline: integer;
begin
  if not Assigned(DataSource) then
    exit;
  if not Assigned(DataSource.DataSet) then
    exit;
  if (DataSource.DataSet.Active = False) then
    exit;
  Offsetline := ValInt(fText);
  fText := AValue;

  posiLig := ValInt(AValue);
  if posiLig <> Offsetline then
  begin
    DataSource.DataSet.DisableControls;
    DataSource.DataSet.MoveBy(posiLig - Offsetline);
    DataSource.DataSet.EnableControls;
    Offsetline := posiLig;
  end;
end;

function TYDbGrid.GetHtmlStyleHeader: TYHtmlStyle;
begin
  Result := fClassHeader.HtmlStyle;
end;

function TYDbGrid.GetfFields: TStrings;
var
  i: integer;
begin
  Result := fFields;
  if (csDesigning in ComponentState) and (fFields.Count = 0) then
  begin
    if Assigned(DataSource) then
      if Assigned(DataSource.DataSet) then
        if DataSource.DataSet.Active then
        begin
          for i := 0 to DataSource.DataSet.Fields.Count - 1 do
            fFields.Add(DataSource.DataSet.Fields[i].FieldName);
        end;
  end;
end;

function TYDbGrid.GetHtmlStyleLine: TYHtmlStyle;
begin
  Result := fClassLine.HtmlStyle;
end;

function TYDbGrid.GetHtmlStyleSelectedLine: TYHtmlStyle;
begin
  Result := fClassSelectedLine.HtmlStyle;
end;

procedure TYDbGrid.SetfFields(AValue: TStrings);
begin
  if fFields = AValue then
    Exit;
  fFields.Text := AValue.Text;
end;

procedure TYDbGrid.SetHtmlStyleHeader(AValue: TYHtmlStyle);
begin
  Self.fClassHeader.HtmlStyle.Assign(AValue);
end;

procedure TYDbGrid.SetHtmlStyleLine(AValue: TYHtmlStyle);
begin
  Self.fClassLine.HtmlStyle.Assign(AValue);
end;

procedure TYDbGrid.SetHtmlStyleSelectedLine(AValue: TYHtmlStyle);
begin
  Self.fClassSelectedLine.HtmlStyle.Assign(AValue);
end;

procedure TYDbGrid.SetOnHeaderClick(AValue: TYHtmlEvent);
begin
  if fOnHeaderClick = AValue then
    Exit;
  fOnHeaderClick := AValue;
{  if (csDesigning in ComponentState) and (assigned(fClassHeader)) then
  begin
  end;   }

end;

procedure TYDbGrid.ClickModif(Sender: TObject);
begin
  EditMode := true;
end;

procedure TYDbGrid.ClickOk(Sender: TObject);
begin
  if ReadOnly = false then EditMode := false;
end;

procedure TYDbGrid.ClickCancel(Sender: TObject);
begin
  if ReadOnly = false then EditMode := false;
end;

procedure TYDbGrid.ClickAdd(Sender: TObject);
begin
  mode_ajout := True;
end;

procedure TYDbGrid.ClickDel(Sender: TObject);
begin
  if not Assigned(DataSource) then
    exit;
  if not Assigned(DataSource.DataSet) then
    exit;
  if (DataSource.DataSet.Active = False) then
    exit;
  DataSource.DataSet.Delete;
  if Assigned(fOnDataCommit) then
    fOnDataCommit(Self);
end;

procedure TYDbGrid.Paint;
var
  i: integer;
begin
  inherited Paint;
  if (csDesigning in ComponentState) then
  begin
    Canvas.Rectangle(0, 0, Width, Height);
    i := 0;
    repeat
      i := i + 40;
      Canvas.Line(i, 0, i, Height);
    until i >= Width;
    i := 0;
    repeat
      i := i + 10;
      Canvas.Line(0, i, Width, i);
    until i >= Height;
  end;
end;


function TYDbGrid.YHTML: string;
var
  i: integer;
  stmp: string;
  sfieldname, sfielddisplayname: string;
  nblig: integer;
  posiLig: integer;
  Bookm: TBookMark;
  sLigTable, sLigTableRev: string;
  bloopTable: boolean;
  bloopbackward: boolean;
  CellHtmlStyle: TYHtmlStyle;
begin
  Result := '';
  if not Assigned(DataSource) then
  begin
    Result := 'No DataSource!';
    exit;
  end;
  if not Assigned(DataSource.DataSet) then
  begin
    Result := 'No DataSet!';
    exit;
  end;
  if (DataSource.DataSet.Active = True) then
  begin
    if DataSource.DataSet.RecordCount <> 0 then
    begin
      fScrollbar.MaxValue := DataSource.DataSet.RecordCount;
      fScrollbar.Text := IntToStr(DataSource.DataSet.RecNo);
      if DisplayRowCount < DataSource.DataSet.RecordCount then
      begin
        fScrollbar.PageSizePercent :=
          (100 * DisplayRowCount) div DataSource.DataSet.RecordCount;
      end
      else
        fScrollbar.PageSizePercent := 100;
    end
    else
    begin
      fScrollbar.MaxValue := 0;
      fScrollbar.Text := '0';
      fScrollbar.PageSizePercent := 100;
    end;
  end;
  if fUseYView = False then
    AsView := False;
  if AsView = True then
  begin
    if (DataSource.DataSet.Active = True) then
      Result := fScrollbar.YHTML + '<iframe name="' + Name +
        '"  id="id' + Name + '" ' + EncodeHtmlClassStyle +
        ' frameBorder="0" src="/view"> <p>Your browser does not support iframes.</p></iframe>';
    exit;
  end;
  ////////////////////////////////Debut/////////////////////
  Result := Result + '<div id="id' + Self.Name + '" ' + Self.EncodeHtmlClassStyle + '>';
  if (fUseYView = False){ and (DataSource.DataSet.Active = True)} then
    Result := Result + fScrollbar.YHTML;
//  fScrollbar.Layout.Generate:=DataSource.DataSet.Active;
  Result := Result + '<div id="id' + Self.fDivGrille.Name + '" ' +
    Self.fDivGrille.EncodeHtmlClassStyle + '>';
  if (DataSource.DataSet.Active = True) then
  begin
    CellHtmlStyle := TYHtmlStyle.Create;
    if Fields.Count = 0 then
    begin
      for i := 0 to DataSource.DataSet.FieldCount - 1 do
      begin
        Fields.Add(DataSource.DataSet.Fields[i].FieldName);
      end;
    end;
  end;
  Result := Result + '<table style = "display: block;overflow-x: auto;white-space: nowrap;">';
  nblig := 0;
  if (DataSource.DataSet.Active = True) then
  begin
    nblig :=DisplayRowCount;
    posiLig := ValInt(Text);
    if posiLig>=DisplayRowCount then posiLig := DisplayRowCount-1;
    DataSource.DataSet.DisableControls;
    nblig := DisplayRowCount-1-posiLig;
    nblig :=  DataSource.DataSet.MoveBy(nblig);
    posiLig := DisplayRowCount-1 -nblig ;
    if posiLig>=DisplayRowCount then posiLig := DisplayRowCount-1;
    nblig := 1-DisplayRowCount;
    nblig := DataSource.DataSet.MoveBy(nblig);
    posiLig := posiLig-(DisplayRowCount-1)-nblig;
    if posiLig < 0 then posiLig := 0;

    Result := Result + '<tr>';

      nblig := 0;
    for i := 0 to fFields.Count - 1 do
    begin
      sfieldname := fFields.Strings[i];
      sfielddisplayname := sfieldname;
      stmp := '';
      CellHtmlStyle.Clear;
      CellHtmlStyle.Assign(fClassHeader.HtmlStyle);
      if (sfieldname = SelectedField) then
        CellHtmlStyle.font_style := [fsBold];
      if Assigned(fOnNeedFieldDefinition) then
        fOnNeedFieldDefinition(sfielddisplayname, CellHtmlStyle);
      if Assigned(fOnHeaderClick) then
        sfielddisplayname := '<input type="submit" name="' + Name + '_Header' +
          sfieldname + '"  id="id' + Name + '_Header' + sfieldname + '" ' +
          ' value="' + sfielddisplayname + '" ' + CellHtmlStyle.EncodeHTMLStyle + '>'
      else
        stmp := ' class="' + fClassHeader.Name + '"';
      Result := Result + '<th' + stmp + ' id="id' + Name + '_Header' +
        sfieldname + '">' + sfielddisplayname + '</th>';
    end;
    Result := Result + '</tr>';
    sLigTable := '';
    sLigTableRev := '';
    bloopTable := (not (DataSource.DataSet.EOF and DataSource.DataSet.BOF));
    if (bloopTable = false) and (EditMode = true) then
    begin
      bloopTable:= true;mode_ajout:=true;
    end;
    bloopbackward := False;
    while bloopTable = True do
    begin
      if nblig = posiLig then
      begin
        if EditMode = False then
          sLigTable := sLigTable + '<tr class="' +
            fClassSelectedLine.Name + ' lines_' + Name + '" data-row=' + IntToStr(nblig) + '>'
        else
          sLigTable := sLigTable + '<tr class="' + fClassSelectedLine.Name + ' lines_' +
            Name + '" data-row=' + IntToStr(nblig) + '>';
        Bookm := DataSource.DataSet.GetBookmark;
      end
      else
      begin
        sLigTable := sLigTable + '<tr class="' + fClassLine.Name + ' lines_' +
          Name + '" data-row=' + IntToStr(nblig) + '>';
      end;

      if (not (DataSource.DataSet.EOF and DataSource.DataSet.BOF)) or
        (EditMode = True) then
        for i := 0 to fFields.Count - 1 do
        begin
          sfieldname := fFields.Strings[i];
          CellHtmlStyle.Clear;
          if Assigned(fOnNeedCellDefinition) then
            fOnNeedCellDefinition(sfieldname, CellHtmlStyle);

          if (mode_ajout = True) and (nblig = posiLig) then
          begin
            stmp := '<input type="text" name="' + Name + sfieldname +
              '" id="id' + Name + sfieldname + '" value="" >';
          end
          else
          begin
//            stmp := V2S(DataSource.DataSet.FieldByName(sfieldname).AsVariant);
            try
            stmp := V2S(DataSource.DataSet.FieldByName(sfieldname).Text );
            except
              stmp:= '';
            end;
            if (EditMode = True) and (nblig = posiLig) then
            begin
              if pos(CR,stmp)>0 then
              begin
                CellHtmlStyle.position_width:= '100%';
                stmp := '<textarea name="' + Name + sfieldname + '" id="id' + Name + sfieldname + '" '+CellHtmlStyle.EncodeHTMLStyle+'>'
                + StrRemplace(stmp, '"', '&quot;') +'</textarea>'
              end
              else
                stmp := '<input type="text" name="' + Name + sfieldname + '" id="id' + Name + sfieldname
                        + '" value="' + StrRemplace(stmp, '"', '&quot;') + '" '+CellHtmlStyle.EncodeHTMLStyle+'>';
            end;
          end;
          if (nblig <> posiLig) and (EditMode = True) then
            sLigTable := sLigTable + '<td class="cells_' + Name + '" data-row=' +
              IntToStr(nblig) + ' data-col=' + IntToStr(i) + '>' + stmp + '</td>'
          else
          begin
            sLigTable := sLigTable + '<td '+CellHtmlStyle.EncodeHTMLStyle+'>' + stmp + '</td>';
          end;
        end;
      sLigTable := sLigTable + '</tr>';

      if not ((mode_ajout = True) and (nblig = posiLig)) then
      begin
        if bloopbackward = True then
        begin
          posiLig:= posiLig+1;
          DataSource.DataSet.prior;
          sLigTableRev := sLigTable + sLigTableRev;
          sLigTable := '';
        end
        else
          DataSource.DataSet.Next;
      end;
      nblig := nblig + 1;

      if DataSource.DataSet.EOF then
      begin
        bloopTable := False;
{        bloopbackward := True;
        sLigTableRev := sLigTable;
        sLigTable := '';
        DataSource.DataSet.MoveBy(-nblig);   }
      end;
      if (bloopbackward = True) and (DataSource.DataSet.BOF = True) then
        bloopTable := False;
      if (nblig >= DisplayRowCount) then
        bloopTable := False;
    end;
    sLigTable := sLigTable + sLigTableRev;

    i := Pos('</td></tr><tr class="', sLigTable);
    if i > 0 then
    begin
      i := i + 21; // length('</td></tr><tr class="');
      sLigTableRev := Copy(sLigTable, i, Length(sLigTable) - i + 1);
      i := i - 8;
      sLigTable := Copy(sLigTable, 1, i) + 'id="id' + Name + '_ligne2" class="' + sLigTableRev;

      system.Delete(sLigTable, 1, 3);
      sLigTable := '<tr id="id' + Name + '_ligne1"' + sLigTable;
    end;
    i := RPos('</td></tr><tr class="', sLigTable);
    if i > 0 then
    begin
      i := i + 21; // length('</td></tr><tr class="');
      sLigTableRev := Copy(sLigTable, i, Length(sLigTable) - i + 1);
      i := i - 8;
      sLigTable := Copy(sLigTable, 1, i) + 'id="id' + Name + '_ligneF" class="' + sLigTableRev;
    end;
    Result := Result + sLigTable;
    if assigned(Bookm) then
      DataSource.DataSet.GotoBookmark(Bookm);
    DataSource.DataSet.EnableControls;
    //    if (mode_modif = true) then DataSource.DataSet.Edit;
    //    if (mode_ajout = true) then DataSource.DataSet.Insert;
    CellHtmlStyle.Free;
  end;
  Result := Result + '</table>';
  fText := IntToStr(posiLig);

  Result := Result + '<input id="iddbgrid_linecount' + Name +
    '" name="dbgrid_linecount' + Name + '" value="' +
    IntToStr(DisplayRowCount) +
    '" style = "width:0px;visibility: hidden;" >';
  if (fReadOnly = False) or (EditMode = true) then
  begin
    if EditMode = true then
      Result := Result + fBtOK.YHTML + fBtCancel.YHTML+ fBtDel.YHTML+fBtAdd.YHTML
    else
       Result := Result + fBtModif.YHTML;
  end;
  Result := Result + IntToStr(nblig) + ' / ' + IntToStr(
    DataSource.DataSet.RecordCount) + ' Lignes';
  Result := Result + '</div>';
  Result := Result + '</div>';

  Result := Result + ('<input id="dbgrid_' + Name + '" name="' + Name + '" value="' + Text + // '">');
    '" style = "display:none;" >');
end;

function TYDbGrid.ScriptInnerFocus(InnerFocusName: string): string;
begin
  Result := 'var fctrl=document.getElementById("id' + Name + InnerFocusName + '");' +
    'if (yinnerfocus== "id' + Name + InnerFocusName + '") {' +
    'fctrl.style.outline = "' + CsFocusOutlineStyle + '";' + 'fctrl.focus();'
    + '} else {' + 'fctrl.style.outline = "";' + '}';
end;

function TYDbGrid.ScriptInnerFocusEvent(InnerFocusName, sparent: string): string;
begin
  Result := 'document.getElementById("id' + Name + InnerFocusName +
    '").addEventListener("focus", function(e) {'
    //   + 'console.log(ycurrentfocus + " " +yinnerfocus);'
    + 'if (' + sparent + 'ycurrentfocus.value != "id' + Name + '") {' +
    sparent + 'yblurApply();' + sParent + 'ywantreturnkey="true";' +
    sparent + 'ycurrentfocus.value = "id' + Name+'";'    // "id'+Name+'";'
    + '}yinnerfocus = "";' + 'yfocus_grid' + Name + '();' + 'yinnerfocus = "id' +
    Name + InnerFocusName + '";' + 'document.getElementById(yinnerfocus).style.outline = "' +
    CsFocusOutlineStyle + '";' + '});';
end;

procedure TYDbGrid.AddCss(Lines: TStrings);
begin
  if AsView = True then
    exit;
  fClassHeader.AddCss(Lines);
  fClassSelectedLine.AddCss(Lines);
  fClassLine.AddCss(Lines);
end;

function TYDbGrid.Yscript: string;
var
  sfieldname: string;
  sparent, sEvents: string;
  actrl: TWinControl;
  i: integer;
begin
  Result := '';
  if AsView = True then
  begin
    Result := Result + 'function yfocus_grid' + Name + '() {if (' + Name +
      '_loaded == 1){' + 'document.getElementById("id' +
      Name + '").contentWindow.yfocus_grid' + Name + '();' +
      '}}' + 'function yblur_grid' + Name + '() {if (' + Name +
      '_loaded == 1){' + 'document.getElementById("id' +
      Name + '").contentWindow.yblur_grid' + Name + '();' + '}}';
//    if (DataSource.DataSet.Active = True) then
      Result := Result + fScrollbar.Yscript;
    exit;
  end;

//  if (DataSource.DataSet.Active = True) then
  begin
    if (fUseYView = False) then
      Result := Result + fScrollbar.Yscript
    else
    begin
      Result := Result + 'parent.document.getElementById("idscrollval_' +
        fScrollbar.Name + '").value="' + fScrollbar.Text + '";';
      Result := Result + 'parent.maxValue' + fScrollbar.Name + '=' +
        IntToStr(fScrollbar.MaxValue) + ';';
      Result := Result + 'parent.pageSizePercent' +
        fScrollbar.Name + '=' + IntToStr(fScrollbar.PageSizePercent) + ';';
    end;
  end;

  actrl := FindViewParent;
  if actrl is TYCustomView then
    sparent := TYCustomView(actrl).JVS_ParentForm
  else
    sparent := '';
  if UseYView = True then
    sparent := sparent + 'parent.';

  if (EditMode = False) then
  begin
    Result := Result + 'var yinnerfocus="";';
    Result := Result + 'var toggler = document.getElementsByClassName("lines_' + Name + '");';
    Result := Result + 'var i;';
    Result := Result + 'for (i = 0; i < toggler.length; i++) {';
    Result := Result + '  toggler[i].addEventListener("click", function() {';
    Result := Result + '    var toggler = document.getElementsByClassName("lines_' +
      Name + '");';
    Result := Result + '    var i,posi;';
    Result := Result + 'yinnerfocus="";';
    Result := Result + '    posi = this.getAttribute("data-row");';
    Result := Result + '    document.getElementById("dbgrid_' + Name + '").value = posi;';
    //dbgrid_
    Result := Result + '    for (i = 0; i < toggler.length; i++) {';
    Result := Result +
      '      if (toggler[i].getAttribute("data-row") == posi) {toggler[i].classList.add("' +
      fClassSelectedLine.Name + '");toggler[i].classList.remove("' + fClassLine.Name + '");}';
    Result := Result + '      else {toggler[i].classList.remove("' +
      fClassSelectedLine.Name + '");toggler[i].classList.add("' + fClassLine.Name +
      '");toggler[i].style.outline = "";}';
    Result := Result + '    };';
    Result := Result + 'yfocus_grid' + Name + '();';
    Result := Result + '  });';
    if Assigned(fOnDblClick) then
    begin
      Result := Result +
        'toggler[i].addEventListener("dblclick", function() {RefreshMe("dblclick_' + Name + '");});';
    end;
    Result := Result + '}';
    Result := Result + 'function yfocus_grid' + Name + '() {' +
      'var ygrstyle="";if (yinnerfocus =="") {ygrstyle="' + CsFocusOutlineStyle +
      '";}' + 'var toggler = document.getElementsByClassName("dbgridline_selected'
      +
      Name + '");' +
      'for (i = 0; i < toggler.length; i++) {toggler[i].style.outline = ygrstyle;}'
      +
      'if (' + sparent + 'ycurrentfocus.value != "id' + Name + '") {' + sparent +
      'yblurApply();' + sparent + 'ycurrentfocus.value = "id' + Name + '";}';
    if fReadOnly = False then
       Result := Result + ScriptInnerFocus('_Mod');// + ScriptInnerFocus('_Del'); // ScriptInnerFocus('_Add') +

    Result := Result + '}' +
      'function yblur_grid' + Name + '() {' +
      'var toggler = document.getElementsByClassName("dbgridline_selected' +
      Name + '");' +
      'for (i = 0; i < toggler.length; i++) {toggler[i].style.outline = "";}';
    if fReadOnly = False then
      Result := Result + 'document.getElementById("id' +
//        Name + '_Add").style.outline = "";' + 'document.getElementById("id' +
        Name + '_Mod").style.outline = "";' +
//        'document.getElementById("id' + Name + '_Del").style.outline = "";' +
        'if (yinnerfocus !="") {document.getElementById(yinnerfocus).blur();yinnerfocus = "";}';
    Result := Result + '}';
  end
  else
  begin
    sEvents := '';
    if SelectedField = '' then
      i := 0
    else
      //    i := DataSource.DataSet.Fields.FieldByName(SelectedField).Index;
      i := fFields.IndexOf(SelectedField);
    if (i>=0) then
      Result := Result + 'var yinnerfocus="id' + Name + fFields[i] + '";'
    else Result := Result + 'var yinnerfocus="";';
    Result := Result + 'function yfocus_grid' + Name + '() {';
    for i := 0 to fFields.Count - 1 do
    begin
      Result := Result + ScriptInnerFocus(fFields[i]);
      sEvents := sEvents + ScriptInnerFocusEvent(fFields[i], sparent);
    end;
    Result := Result + ScriptInnerFocus('_OK');
    Result := Result + ScriptInnerFocus('_Cancel');
    Result := Result + ScriptInnerFocus('_Del');
    Result := Result + ScriptInnerFocus('_Add');
    Result := Result + '}';

    Result := Result + 'var toggler = document.getElementsByClassName("cells_' + Name + '");';
    Result := Result + 'var i;';
    Result := Result + 'for (i = 0; i < toggler.length; i++) {';
    //    result := result +'if(i!='+Text+'){';
    Result := Result + '  toggler[i].addEventListener("click", function() {';
    Result := Result + '    var toggler = document.getElementsByClassName("lines_' +
      Name + '");';
    Result := Result + '    var i,posi;';
    //    result := result +'yinnerfocus="";';
    Result := Result + '    posi = this.getAttribute("data-row");';
    Result := Result + '    i = this.getAttribute("data-col");';
    Result := Result + '    document.getElementById("dbgrid_' + Name + '").value = posi;';
    //dbgrid_
    Result := Result + sparent + 'ycurrentfocus.value = "id' + Name + '";';
    Result := Result + 'RefreshMe("cells_' + Name + ':"+String(i));';
    Result := Result + '});';
    Result := Result + '}';
    //    result := result +'}';


    Result := Result + sEvents + ScriptInnerFocusEvent('_OK', sparent) +
      ScriptInnerFocusEvent('_Cancel', sparent);
    Result := Result + 'function yblur_grid' + Name + '() {';
    Result := Result + sparent+ 'ycurrentfocus.value = "idHTMLEXIT"';
//    Result := Result + 'RefreshMe("");';

{    for i := 0 to fFields.Count-1 do
    begin
       result :=result + 'document.getElementById("id' + Name+fFields[i]+'").style.outline = "";'
    end;  }

    Result := Result + '}';
  end;
  Result := Result + 'function ycalculnblig_' + Name + '() {';
  if Assigned(DataSource) then
    if (AutoExtand = True) and (Assigned(DataSource.DataSet)) then
    begin
      if DataSource.DataSet.Active = True then
      begin
        if (fFields.Count > 0) and (DataSource.DataSet.RecordCount > 2) then
        begin
          ;
          sfieldname := fFields.Strings[0];
          if UseYView then
            Result := Result + 'var yheight=window.innerHeight-document.getElementById("id' +
              Name + '_Header' + sfieldname + '").getBoundingClientRect().bottom;'
          else
            Result := Result + 'var yheight=window.innerHeight-10-document.getElementById("id'
              +
              Name + '_Header' +
              sfieldname + '").getBoundingClientRect().bottom;';


          Result := Result + 'var yligheight= document.getElementById("id'
            + Name +
            '_ligne2").getBoundingClientRect().top-document.getElementById("id'
            +
            Name + '_ligne1").getBoundingClientRect().top;';

          Result := Result + 'yheight= yheight+document.getElementById("id'
            + Name +
            '_ligneF").getBoundingClientRect().bottom-document.getElementById("iddbgrid_linecount'
            + Name + '").getBoundingClientRect().bottom;';
          Result := Result +
            'if (yligheight!=0) {var ynbliggrid = Math.trunc(yheight/yligheight);' +
            'if (ynbliggrid<3) {ynbliggrid=3;}document.getElementById(id="iddbgrid_linecount'
            +
            Name + '").value = ynbliggrid;}';
        end;
      end;
    end;
  Result := Result + '} ycalculnblig_' + Name + '();';


  // result := result + 'function yfocus_'+Name+'() {document.getElementById("id'+Name+'").style.color = "red";}';
  // result := result + 'function yblur_'+Name+'() {document.getElementById("id'+Name+'").style.color = "blue";}';
  // result := result + 'document.getElementById("id'+Name+'").addEventListener("focus",yfocus_'+Name+');';
end;

function TYDbGrid.YScript_browserResize: string;
begin
  Result := '';
  if not Assigned(DataSource) then
    exit;
  if not Assigned(DataSource.DataSet) then
    exit;
  if AsView = True then
  begin
//    if (DataSource.DataSet.Active = True) then
      Result := {fScrollbar.Layout.YScript_browserResize+}
        fScrollbar.YScript_browserResize;
    exit;
  end;
  if UseYView = True then
    Result := ''
  else
//  if (DataSource.DataSet.Active = True) then
  begin
    Result := {fScrollbar.Layout.YScript_browserResize +}
      fScrollbar.YScript_browserResize;
    if (AutoExtand = True) and (fFields.Count > 0) and
      (DataSource.DataSet.RecordCount > 2) then
      Result := Result + 'ycalculnblig_' + Name + '();';
  end;
end;

function TYDbGrid.Yscript_mousemove: string;
begin
  Result := '';
  if not Assigned(DataSource) then
    exit;
  if not Assigned(DataSource.DataSet) then
    exit;
//  if (DataSource.DataSet.Active) = False then
//    exit;
  if AsView = True then
    Result := fScrollbar.Yscript_mousemove
  else if UseYView = False then
    Result := fScrollbar.Yscript_mousemove;
end;

function TYDbGrid.Yscript_touchmove: string;
begin
  Result := '';
  if not Assigned(DataSource) then
    exit;
  if not Assigned(DataSource.DataSet) then
    exit;
//  if (DataSource.DataSet.Active) = False then
//    exit;
  if AsView = True then
    Result := fScrollbar.Yscript_touchmove
  else if UseYView = False then
    Result := fScrollbar.Yscript_touchmove;
end;

function TYDbGrid.Yscript_mouseup: string;
begin
  Result := '';
  if not Assigned(DataSource) then
    exit;
  if not Assigned(DataSource.DataSet) then
    exit;
//  if (DataSource.DataSet.Active) = False then
//    exit;
  if AsView = True then
    Result := fScrollbar.Yscript_mouseup
  else if UseYView = False then
    Result := fScrollbar.Yscript_mouseup;
end;

function TYDbGrid.Yscript_touchend: string;
begin
  Result := '';
  if not Assigned(DataSource) then
    exit;
  if not Assigned(DataSource.DataSet) then
    exit;
//  if (DataSource.DataSet.Active) = False then
//    exit;
  if AsView = True then
    Result := fScrollbar.Yscript_touchend
  else if UseYView = False then
    Result := fScrollbar.Yscript_touchend;
end;

function TYDbGrid.Yscript_keydown: string;
var
  sparent: string;
  i: integer;
  sEltId: string;
begin
  Result := '';
  sparent := '';
  if not Assigned(DataSource) then
    exit;
  if not Assigned(DataSource.DataSet) then
    exit;
  if (DataSource.DataSet.Active) = False then
    exit;
  if AsView = True then
  begin
    sparent := 'document.getElementById("id' + Name + '").contentWindow.';
  end;
  if EditMode = True then
  begin
    Result := Result + 'if ((yinnerfocus == "id' + Name + '_Mod") || (yinnerfocus == "id' + Name + '_Add") || (yinnerfocus == "id' + Name + '_OK") || (yinnerfocus == "id' + Name + '_Del") || (yinnerfocus == "id' +
      Name + '_Cancel")) {if (key == 13){key=-1;document.getElementById(yinnerfocus).click();}if (key == 37) {key=38;};if (key == 39) {key=40;}}';
    Result := Result + 'if (key == 27) {key = -1;document.getElementById("id' +
      Name + '_Cancel").click();}';
    Result := Result +
      'if ((!(event.shiftKey || event.metaKey || event.altKey || event.ctrlKey)) &&('
      +
      '((key == 13) || (key == 40)) ||' + '(key == 9) ))  {switch (yinnerfocus) {';
    for i := 0 to fFields.Count - 1 do
    begin
      if i = (fFields.Count - 1) then
        sEltId := 'id' + Name + '_OK'
      else
        sEltId := 'id' + Name + fFields[i + 1];
      Result := Result + 'case "id' + Name + fFields[i] + '":{if (key!=40){key=-1;yinnerfocus = "' +
        sEltId + '";}break;}';
    end;
    Result := Result + 'case "id' + Name + '_OK":{key=-1;yinnerfocus = "' + 'id' +
      Name + '_Cancel";break;}';
    Result := Result + 'case "id' + Name + '_Cancel":{key=-1;yinnerfocus = "' + 'id' +
      Name + '_Del";break;}';
    Result := Result + 'case "id' + Name + '_Del":{key=-1;yinnerfocus = "' + 'id' +
    Name + '_Add";break;}';
    Result := Result + 'case "id' + Name + '_Add":{key=-1;yinnerfocus = "' + 'id' +
    Name + fFields[0] + '";break;}';
    Result := Result + '}yfocus_grid' + Name + '();}';
    Result := Result + 'if (' +
      '((!(event.shiftKey || event.metaKey || event.altKey || event.ctrlKey)) &&(key == 38)) || '
      + '((!(event.metaKey || event.altKey || event.ctrlKey))&&(key == 9)&&event.shiftKey )) {switch (yinnerfocus) {';
    for i := 0 to fFields.Count - 1 do
    begin
      if i = 0 then
        sEltId := 'id' + Name + '_Add'
      else
        sEltId := 'id' + Name + fFields[i - 1];
      Result := Result + 'case "id' + Name + fFields[i] + '":{if (key!=38){key=-1;yinnerfocus = "' +
        sEltId + '";}break;}';
    end;
    Result := Result + 'case "id' + Name + '_OK":{key=-1;yinnerfocus = "' + 'id' +
      Name + fFields[fFields.Count - 1] + '";break;}';
    Result := Result + 'case "id' + Name + '_Cancel":{key=-1;yinnerfocus = "' + 'id' +
      Name + '_OK";break;}';
    Result := Result + 'case "id' + Name + '_Del":{key=-1;yinnerfocus = "' + 'id' +
      Name + '_Cancel";break;}';
    Result := Result + 'case "id' + Name + '_Add":{key=-1;yinnerfocus = "' + 'id' +
      Name + '_Del";break;}';
    Result := Result + '}yfocus_grid' + Name + '();}';
  end
  else
  begin     /// pas en mode edition
    if fReadOnly = False then
    begin
      Result := Result + 'if (yinnerfocus == "id' + Name + '_Mod") {if (key == 13){key=-1;document.getElementById(yinnerfocus).click();}if (key == 37) {key=38;}}';  //if (key == 39) {key=40;}

     Result := Result + 'if ((!(event.shiftKey || event.metaKey || event.altKey || event.ctrlKey))&&(key == 9)&&(yinnerfocus == "")){yinnerfocus = "' + 'id' +Name + '_Mod";yfocus_grid' + Name + '();key=-1;}';

          Result := Result + 'if (' +
            '((!(event.shiftKey || event.metaKey || event.altKey || event.ctrlKey)) &&(key == 38)) || '
              + '((!(event.metaKey || event.altKey || event.ctrlKey))&&(key == 9)&&event.shiftKey )) {switch (yinnerfocus) {'
          +'case "id' + Name + '_Mod":{document.getElementById(yinnerfocus).blur();yinnerfocus = "";yfocus_grid'+ Name +'();key=-1;break;}'
//          +'case "":if (key !=13) {yinnerfocus = "' + 'id' +Name + '_Mod"} else {key=0;break;}'
          + '}'  //yfocus_grid' + Name + '();key=-1;
       + '}';
    end;

  end;


    Result := Result + 'if (key == 36) {' + sparent + 'RefreshMe("scrollfirst_' +
      fScrollbar.Name + '");event.preventDefault;return false;}' +
      'if (key == 35) {' + sparent + 'RefreshMe("scrolllast_' + fScrollbar.Name +
      '");event.preventDefault;return false;}' +
      'if (key == 38) {' + sparent + 'RefreshMe("scrollprior_' + fScrollbar.Name +
      '");event.preventDefault;return false;}' +
      'if (key == 40) {' + sparent + 'RefreshMe("scrollnext_' + fScrollbar.Name +
      '");event.preventDefault;return false;}' +
      'if (key == 33) {' + sparent + 'RefreshMe("scrollpriorpg_' + fScrollbar.Name +
      '");event.preventDefault;return false;}' +
      'if (key == 34) {' + sparent + 'RefreshMe("scrollnextpg_' + fScrollbar.Name +
      '");event.preventDefault;return false;}' +
      'if (key == -1) {event.preventDefault;return false;}';
end;

procedure TYDbGrid.FillFromRequest(ARequestContent: TStrings;
  var vOnClick: TYHtmlEvent;
  var Sender: TObject; YHTMLEXIT: string;var ErrorMessage : string);
var
  i: integer;
  sfieldname, stmp: string;
  bAcceptValue, ValueChanged: boolean;
begin
  if Self.Generate = false then exit;
  if not Assigned(DataSource) then
    exit;
  if not Assigned(DataSource.DataSet) then
    exit;
  if (DataSource.DataSet.Active) = False then
    exit;

  bAcceptValue := False;
  ValueChanged := False;

  if (EditMode=true) and (ARequestContent.IndexOfName(fBtCancel.Name) = -1) then
  begin
    bAcceptValue := True;
  end;
  stmp := '';
  for i := 0 to fFields.Count - 1 do
  begin
    sfieldname := fFields.Strings[i];
    if (bAcceptValue = True) and
      (ARequestContent.IndexOfName(Name + sfieldname) >= 0) then
    begin
      stmp := stmp + sfieldname + ':' + DataSource.DataSet.FieldByName(
        sfieldname).AsString + ' | ';
      if (DataSource.DataSet.FieldByName(sfieldname).ReadOnly = False) and (DataSource.DataSet.FieldByName(sfieldname).FieldKind = fkData) then
      begin
        if DataSource.DataSet.FieldByName(sfieldname).AsString <>
          (ARequestContent.Values[Name + sfieldname]) then
        begin
          if ValueChanged = False then
          begin
            if (EditMode = True) then
              if mode_ajout = true then DataSource.DataSet.Insert
              else DataSource.DataSet.Edit;
          end;
//          TMemoField(DataSource.DataSet.FieldByName(sfieldname)).Value:=;
//          if  DataSource.DataSet.FieldByName(sfieldname) is TMemoField then
            try
              DataSource.DataSet.FieldByName(sfieldname).Value := (ARequestContent.Values[Name + sfieldname]);
            except
              on E : Exception do
                  begin
                    ErrorMessage:= ErrorMessage + E.ClassName + ' signale :<br>'+E.Message+ '<br>';
//                    if Assigned(fOnDataRollback) then fOnDataRollback(Self);
                  end;
            end;
//          else
//            DataSource.DataSet.FieldByName(sfieldname).AsString := (ARequestContent.Values[Name + sfieldname]);
          ValueChanged := True;
        end;
      end;
      stmp := stmp + sfieldname + ':' + DataSource.DataSet.FieldByName(
        sfieldname).AsString + ' | ';
    end;
    if (ARequestContent.IndexOfName(Name + '_Header' + sfieldname) >= 0) then
    begin
      SelectedField := sfieldname;
      if Assigned(fOnHeaderClick) then
      begin
        vOnClick := TYHtmlEvent(fOnHeaderClick);
        Sender := self;
      end;
    end;
  end;

  if (bAcceptValue = True) and (ValueChanged = True) then
  begin
    try
      mode_ajout:=false;
      DataSource.DataSet.Post;
      if Assigned(fOnDataCommit) then
        fOnDataCommit(Self);
    except
      on E : Exception do
          begin
            ErrorMessage := ErrorMessage+E.ClassName + ' signale :<br>'+E.Message+ '<br>';
            DataSource.DataSet.Cancel;
            if Assigned(fOnDataRollback) then fOnDataRollback(Self);
          end;
    end;
  end;

  if ARequestContent.IndexOfName(Name) >= 0 then
    SetText(ARequestContent.Values[Name]);
  if ARequestContent.IndexOfName('dbgrid_linecount' + Name) >= 0 then
    DisplayRowCount := Valint(ARequestContent.Values['dbgrid_linecount' + Name]);
  if (YHTMLEXIT = 'dblclick_' + Name) then
  begin
    vOnClick := TYHtmlEvent(fOnDblClick);
    Sender := self;
  end;

  //    if (mode_modif or mode_ajout) = false  then
  //    begin
  if (YHTMLEXIT = 'scrolllast_scrollbar_' + Name) then
    scrollbottom(self);
  if (YHTMLEXIT = 'scrollprior_scrollbar_' + Name) then
    scrollup(self);
  if (YHTMLEXIT = 'scrollfirst_scrollbar_' + Name) then
    scrolltop(self);
  if (YHTMLEXIT = 'scrollnext_scrollbar_' + Name) then
    scrolldown(self);
  if (YHTMLEXIT = 'scrollcursor_scrollbar_' + Name) then
    scrollcursor(ARequestContent.Values['scrollbar_' + Name]);
  if (YHTMLEXIT = 'scrollpriorpg_scrollbar_' + Name) then
    scrollpgup(self);
  if (YHTMLEXIT = 'scrollnextpg_scrollbar_' + Name) then
    scrollpgdown(self);
  //    end;

  if ARequestContent.IndexOfName(fBtOK.Name) >= 0 then
    ClickOk(self);
  stmp := StrToken(YHTMLEXIT, ':');
  if stmp = ('scrollcursor_scrollbar_' + Name) then
  begin
    if YHTMLEXIT <> '' then
      scrollcursor(YHTMLEXIT);
  end;

  if stmp = ('cells_' + Name) then
  begin
    try
      if YHTMLEXIT <> '' then
        SelectedField := fFields[ValInt(YHTMLEXIT)];
    except
      SelectedField := '';
    end;
  end;
end;

procedure TYDbGrid.scrollbottom(Sender: TObject);
begin
  if not Assigned(DataSource) then
    exit;
  if not Assigned(DataSource.DataSet) then
    exit;
  if (DataSource.DataSet.Active) = False then
    exit;
  DataSource.DataSet.Last;
  fText := IntToStr(DisplayRowCount - 1);
end;

procedure TYDbGrid.scrollup(Sender: TObject);
begin
  if not Assigned(DataSource) then
    exit;
  if not Assigned(DataSource.DataSet) then
    exit;
  if (DataSource.DataSet.Active) = False then
    exit;
  DataSource.DataSet.prior;
end;

procedure TYDbGrid.scrolldown(Sender: TObject);
begin
  if not Assigned(DataSource) then
    exit;
  if not Assigned(DataSource.DataSet) then
    exit;
  if (DataSource.DataSet.Active) = False then
    exit;
  DataSource.DataSet.Next;
end;

procedure TYDbGrid.scrolltop(Sender: TObject);
begin
  fText := '0';//intToStr(Offsetline);
  if not Assigned(DataSource) then
    exit;
  if not Assigned(DataSource.DataSet) then
    exit;
  if (DataSource.DataSet.Active) = False then
    exit;
  DataSource.DataSet.First;
end;

procedure TYDbGrid.scrollpgup(Sender: TObject);
begin
  if not Assigned(DataSource) then
    exit;
  if not Assigned(DataSource.DataSet) then
    exit;
  if (DataSource.DataSet.Active) = False then
    exit;
  DataSource.DataSet.MoveBy(-fDisplayRowCount);
end;

procedure TYDbGrid.scrollpgdown(Sender: TObject);
begin
  if not Assigned(DataSource) then
    exit;
  if not Assigned(DataSource.DataSet) then
    exit;
  if (DataSource.DataSet.Active) = False then
    exit;
  DataSource.DataSet.MoveBy(fDisplayRowCount);
end;

procedure TYDbGrid.scrollcursor(position: string);
var
  LePosition: integer;
begin
  if not Assigned(DataSource) then
    exit;
  if not Assigned(DataSource.DataSet) then
    exit;
  if (DataSource.DataSet.Active) = False then
    exit;
  LePosition := ValInt(position);
  DataSource.DataSet.First;
  DataSource.DataSet.MoveBy(LePosition);
end;

end.
procedure Register;
implementation
procedure Register;
begin
  {$I ydbgrid_icon.lrs}  RegisterComponents('YHTML', [TYDbGrid]);
end;
end.
