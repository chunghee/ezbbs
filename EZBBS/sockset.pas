unit sockset;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TSocketSetup = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    telnetPortnum: TEdit;
    Label2: TLabel;
    httpPortnum: TEdit;
    Button1: TButton;
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure telnetPortnumKeyPress(Sender: TObject; var Key: Char);
    procedure httpPortnumKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SocketSetup: TSocketSetup;

implementation

uses MainUnit,declare;

{$R *.DFM}

procedure TSocketSetup.Button2Click(Sender: TObject);
begin
     PLAYVOICE('cancel');
     close;
end;

procedure TSocketSetup.Button1Click(Sender: TObject);
begin
    if telnetportnum.text='' then
       telnetportnum.text:='0';
    if httpportnum.text='' then
       httpportnum.text:='0';
    if httpportnum.text=telnetportnum.text then begin
       PLAYVOICE('error');
       messagedlg('두 포트의 번호가 같을 수 없습니다.',mtError,[mbOK],0);
       exit;
    end;
     PLAYVOICE('apply');
    telnetport:=strtoint(telnetportnum.text);
    httpport:=strtoint(httpportnum.text);
    close;
end;

procedure TSocketSetup.FormShow(Sender: TObject);
begin
     telnetportnum.text:=inttostr(telnetport);
     httpportnum.text:=inttostr(httpport);
end;

procedure TSocketSetup.telnetPortnumKeyPress(Sender: TObject;
  var Key: Char);
begin
     if key=chr(vk_back) then
        exit;
     if (key<'0') or (key>'9') then
        key:=chr(0);
     if telnetportnum.text<>'' then
       if strtoint(telnetportnum.text)>9999 then
          key:=chr(0);
end;

procedure TSocketSetup.httpPortnumKeyPress(Sender: TObject; var Key: Char);
begin
     if key=chr(vk_back) then
        exit;
     if (key<'0') or (key>'9') then
        key:=chr(0);
     if httpportnum.text<>'' then
       if strtoint(httpportnum.text)>9999 then
          key:=chr(0);
end;

end.
