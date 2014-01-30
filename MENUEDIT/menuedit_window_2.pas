unit menuedit_window_2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls;

type
  TForm2 = class(TForm)
    ComboBox1: TComboBox;
    Kind: TStaticText;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    Ok: TButton;
    Cancel: TButton;
    Label3: TLabel;
    Edit3: TEdit;
    ListBox1: TListBox;
    Label4: TLabel;
    ADD: TButton;
    REMOVE: TButton;
    Memo1: TMemo;
    procedure ComboBox1KeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure CancelClick(Sender: TObject);
    procedure OkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Edit2KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure REMOVEClick(Sender: TObject);
    procedure ADDClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses menuedit,menuedit_idinput;

{$R *.DFM}
procedure buttonshow;
begin
  repeat
    if form2.combobox1.Text='' then break;
    if form2.edit1.text='' then break;
    if form2.edit2.text='' then break;
    if form2.edit3.text='' then break;
    form2.ok.enabled:=true;
    exit;
  until true;
  form2.ok.enabled:=false;
end;

procedure TForm2.ComboBox1KeyPress(Sender: TObject; var Key: Char);
begin
     Key:=chr(0);
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     Form1.enabled:=true;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
     ComboBox1.Items.Add('엄마메뉴');
     ComboBox1.Items.Add('게시판');
     ComboBox1.Items.Add('대화방');
     ComboBox1.Items.Add('편지읽기');
     ComboBox1.Items.Add('편지쓰기');
     ComboBox1.Items.Add('개인정보 변경');
     ComboBox1.Items.Add('관리자게시판');
     ComboBox1.Items.Add('익명게시판');
end;

procedure TForm2.CancelClick(Sender: TObject);
begin
     form2.Close;
     combobox1.Text:='';
     edit1.text:='';
     edit2.text:='';
     edit3.text:='';
end;

procedure TForm2.OkClick(Sender: TObject);
var tmpnode:ttreenode;
    tmpdata:^tnodedata;
    tmpadmin2,tmpadmin:padminlist;
    i:integer;
begin
     if form2.caption='ADD' then begin
        tmpnode:=selectednode.Owner.AddChild(SelectedNode,Edit2.text);
        SelectedNode.Expand(false);
        new(tmpdata);
        fillchar(tmpdata^,sizeof(tmpdata^),0);
        tmpnode.data:=tmpdata;
        tnodedata(tmpnode.Data^).adminlist.next:=nil;
     end else begin
         tmpnode:=Selectednode;
         tmpdata:=SelectedNode.data;
         tmpnode.Text:=edit2.text;
     end;

     tmpadmin:=Tnodedata(tmpnode.data^).adminlist.next;
     while (tmpadmin<>nil) do begin
           tmpadmin2:=tmpadmin;
           tmpadmin:=tmpadmin.next;
           dispose(tmpadmin2);
     end;
     Tnodedata(tmpnode.data^).adminlist.next:=nil;
     for i:=0 to listbox1.Items.count-1 do begin
         new(tmpadmin);
         tmpadmin.id:=listbox1.items[i];
         tmpadmin.next:=tnodedata(tmpnode.data^).adminlist.next;
         tnodedata(tmpnode.data^).adminlist.next:=tmpadmin;         
     end;

     tmpdata.kind:=combobox1.Items.IndexOf(Combobox1.text);
     tmpdata.index:=edit1.text;
     tmpdata.name:=edit2.text;
     if assigned(tmpnode.parent) then tmpdata.dir:=tnodedata(tmpnode.Parent.Data^).Dir+'\'+edit3.text;
     Edit3.Enabled:=true;
     form2.close;
end;

procedure TForm2.FormShow(Sender: TObject);
begin
     ok.enabled:=false;
     if (selectednode.parent=nil) and (Form2.Caption='Edit')then
        edit3.enabled:=false;

end;

procedure TForm2.ComboBox1Change(Sender: TObject);
begin
    buttonshow;
end;

procedure TForm2.Edit2KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     ButtonShow;
end;

procedure TForm2.REMOVEClick(Sender: TObject);
begin
     ok.enabled:=true;
     listbox1.Items.Delete(listbox1.itemindex);
end;

procedure TForm2.ADDClick(Sender: TObject);
begin
     input.showmodal;
     ok.enabled:=true;
end;

end.
