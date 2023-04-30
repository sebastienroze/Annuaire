unit sysprocs;

{$mode objfpc}{$H+}

interface

function GetAdresseIp() : string;


implementation

uses Winsock;

function GetAdresseIp() : string;
type
  TaPInAddr = array [0..10] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  phe : PHostEnt;
  pptr : PaPInAddr;
  Buffer : array [0..63] of char;
  I       : Integer;
  GInitData           : TWSADATA;
  ip_machine,ip:string;
begin
  GInitData.wVersion := 0;
  WSAStartup($101, GInitData);
  ip_machine := '';
  GetHostName(Buffer, SizeOf(Buffer));
  phe :=GetHostByName(buffer);
  if phe = nil then Exit;
  pptr := PaPInAddr(Phe^.h_addr_list);
  I := 0;
  while (pptr^[I] <> nil) {and (ip_machine = '')} do
  begin
      // l'IP est stockée ci-dessous
      ip := StrPas(inet_ntoa(pptr^[I]^));
//     ShowMessage(ip);
      if ip <> '' then
      begin
       // if Copy(ip,1,6) <> '127.0.' then
        begin
//          if (Copy(ip,1,10) = '192.168.1.')  then
          begin
             ip_machine := ip;
          end;
        end;
      end;
      Inc(I);
  end;
  WSACleanup;
  result := ip_machine;
  if (ip <> '') and (result = '') then result := IP;
//  result := '127.0.0.1';
end;


end.

