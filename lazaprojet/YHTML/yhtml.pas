{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit YHTML;

{$warn 5023 off : no warning about unused units}
interface

uses
  YHtmlControl, strprocs, YText, YButton, YDiv, YBr, YInput, YMemo, YCombo, 
  YCheckBox, YImage, YScrollbar, YDBInput, YDBMemo, YDbGrid, YServer, 
  YHtmlDocument, YClass, YView, YLayout, YTimer, YSound, YKeyboard, 
  YJavascript, YCanvas, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('YText', @YText.Register);
  RegisterUnit('YButton', @YButton.Register);
  RegisterUnit('YDiv', @YDiv.Register);
  RegisterUnit('YBr', @YBr.Register);
  RegisterUnit('YInput', @YInput.Register);
  RegisterUnit('YMemo', @YMemo.Register);
  RegisterUnit('YCombo', @YCombo.Register);
  RegisterUnit('YCheckBox', @YCheckBox.Register);
  RegisterUnit('YImage', @YImage.Register);
  RegisterUnit('YScrollbar', @YScrollbar.Register);
  RegisterUnit('YDBInput', @YDBInput.Register);
  RegisterUnit('YDBMemo', @YDBMemo.Register);
  RegisterUnit('YDbGrid', @YDbGrid.Register);
  RegisterUnit('YServer', @YServer.Register);
  RegisterUnit('YHtmlDocument', @YHtmlDocument.Register);
  RegisterUnit('YClass', @YClass.Register);
  RegisterUnit('YView', @YView.Register);
  RegisterUnit('YLayout', @YLayout.Register);
  RegisterUnit('YTimer', @YTimer.Register);
  RegisterUnit('YSound', @YSound.Register);
  RegisterUnit('YKeyboard', @YKeyboard.Register);
  RegisterUnit('YJavascript', @YJavascript.Register);
  RegisterUnit('YCanvas', @YCanvas.Register);
end;

initialization
  RegisterPackage('YHTML', @Register);
end.
