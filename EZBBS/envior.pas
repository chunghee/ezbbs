unit envior;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TEnViorSet = class(TForm)
    BBName: TEdit;
    Label1: TLabel;
    LogonMsg: TMemo;
    Label2: TLabel;
    RadioGroup1: TRadioGroup;
    Button1: TButton;
    Button2: TButton;
    RadioGroup2: TRadioGroup;
    RadioGroup3: TRadioGroup;
    RadioGroup4: TRadioGroup;
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EnViorSet: TEnViorSet;
                
implementation

uses MainUnit,Declare;

{$R *.DFM}

procedure TEnViorSet.FormShow(Sender: TObject);
begin
     LogonMsg.Text:=LoginMessage;
     BBName.Text:=BBSName;
     if IsFree then
        radiogroup1.itemindex:=0
     else
        radiogroup1.itemindex:=1;
     if RunBind then
        radiogroup2.itemindex:=0
     else
         radiogroup2.itemindex:=1;
     if RunHide then
        radiogroup3.itemindex:=0
     else
         radiogroup3.itemindex:=1;
     if MultiLogin then
        radiogroup4.itemindex:=0
     else
         radiogroup4.itemindex:=1;

end;

procedure TEnViorSet.Button2Click(Sender: TObject);
begin
     PLAYVOICE('cancel');
     close;

end;

procedure TEnViorSet.Button1Click(Sender: TObject);
begin
     if radiogroup1.itemindex=0 then
        isfree:=true
     else
         isfree:=false;

     if radiogroup2.itemindex=0 then
        RunBind:=true
     else
         RunBind:=false;

     if radiogroup3.itemindex=0 then
        RunHide:=true
     else
         RunHide:=false;

     if radiogroup4.itemindex=0 then
        MultiLogin:=true
     else
         MultiLogin:=false;

     PLAYVOICE('APPLY');
     loginmessage:=logonmsg.text;
     bbsname:=bbname.text;
     close;
end;

end.
