unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TDataEdit = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Button1: TButton;
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataEdit: TDataEdit;

implementation

uses Unit1;

{$R *.DFM}









procedure TDataEdit.Button2Click(Sender: TObject);
begin
     close;
end;

procedure TDataEdit.Button1Click(Sender: TObject);
var file1:textfile;
begin
     assignfile(file1,extractfilepath(application.exename)+'userdata\'+edit1.text+'.dat');
     rewrite(file1);
     writeln(file1,edit3.text);
     writeln(file1,edit2.text);
     writeln(file1,edit4.text);
     writeln(file1,edit5.text);
     writeln(file1,edit6.text);
     writeln(file1,edit7.text);
     writeln(file1,edit8.text);
     writeln(file1,edit9.text);
     writeln(file1);
     writeln(file1,edit10.text);
     writeln(file1,edit11.text);
     writeln(file1,edit12.text);
     closefile(file1);
     useredit.listview1.selected.caption:=edit1.text;
     useredit.listview1.selected.subitems[0]:=edit2.text;
     useredit.listview1.selected.subitems[10]:=edit3.text;
     useredit.listview1.selected.subitems[1]:=edit4.text;
     useredit.listview1.selected.subitems[2]:=edit5.text;
     useredit.listview1.selected.subitems[3]:=edit6.text;
     useredit.listview1.selected.subitems[4]:=edit7.text;
     useredit.listview1.selected.subitems[5]:=edit8.text;
     useredit.listview1.selected.subitems[6]:=edit9.text;
     useredit.listview1.selected.subitems[7]:=edit10.text;
     useredit.listview1.selected.subitems[8]:=edit11.text;
     useredit.listview1.selected.subitems[9]:=edit12.text;
     close;
end;

end.
