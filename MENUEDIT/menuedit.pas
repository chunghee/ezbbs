unit menuedit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, ComCtrls;

type
  PAdminList=^TAdminList;
  TAdminList=record
         id:string;
         next:PAdminList;
  end;
  PNodeData=^TNodeData;
  TNodeData=record
    AdminList:TAdminList;
    kind:integer;
    choicenum:string;
    dir:string;
    index:string;
    name:string;
  end;
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Save: TMenuItem;
    Exit1: TMenuItem;
    N2: TMenuItem;
    TreeView1: TTreeView;
    PopupMenu1: TPopupMenu;
    nErase: TMenuItem;
    Button1: TButton;
    Button3: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Button2: TButton;
    nEdit: TMenuItem;
    nAdd: TMenuItem;
    Load1: TMenuItem;
    N1: TMenuItem;
    About1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure nEraseClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure Button3Click(Sender: TObject);
    procedure APPEND1Click(Sender: TObject);
    procedure nEditClick(Sender: TObject);
    procedure TreeView1Edited(Sender: TObject; Node: TTreeNode;
      var S: String);
    procedure Exit1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SaveClick(Sender: TObject);
    procedure Load1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  TopMenuDir:string;
  selectedNode:TTreeNode;
implementation

uses menuedit_window_2, menuedit_about;

{$R *.DFM}
procedure SaveMenu(CurrentNode:ttreenode);
var tmphandle:integer;
    finddata:twin32finddata;
    file1:textfile;
    ptmp:padminlist;
    i:integer;
begin
   with TNodeData(CurrentNode.Data^) do begin
     createdirectory(pchar(dir),nil);
     tmphandle:=findfirstfile(pchar(dir+'\*.*'),finddata);
     while (tmphandle>-1) do begin
       if finddata.dwfileattributes=file_attribute_directory then begin
         if (string(finddata.cFilename)<>'.') and
           (string(finddata.cFileName)<>'..') then
           if fileexists(dir+'\'+finddata.cfilename+'\menu.dat') then begin
             setfileattributes(pchar(dir+'\'+finddata.cfilename+'\menu.dat'),FILE_ATTRIBUTE_NORMAL);
             setfileattributes(pchar(dir+'\'+finddata.cfilename+'\menu.bak'),FILE_ATTRIBUTE_NORMAL);
             AssignFile(file1, dir+'\'+finddata.cfilename+'\menu.dat');
             if fileexists(dir+'\'+finddata.cfilename+'\menu.bak') then
                deletefile(dir+'\'+finddata.cfilename+'\menu.bak');
             rename(file1,dir+'\'+finddata.cfilename+'\menu.bak');
           end;
       end;

       if not findnextfile(tmphandle,finddata) then
           tmphandle:=-1;
     end;

     setfileattributes(pchar(dir+'\menu.dat'),FILE_ATTRIBUTE_NORMAL);
     setfileattributes(pchar(dir+'\menu.bak'),FILE_ATTRIBUTE_NORMAL);
     setfileattributes(pchar(dir+'\admin.cfg'),FILE_ATTRIBUTE_NORMAL);

     assignfile(file1,dir+'\menu.dat');
     rewrite(file1);
     writeln(file1,inttostr(kind));
     writeln(file1,index);
     writeln(file1,name);
     closefile(file1);

     assignfile(file1,dir+'\admin.cfg');
     rewrite(file1);
     ptmp:=adminlist.next;
     while (ptmp<>nil) do begin
           writeln(file1,ptmp.id);
           ptmp:=ptmp.next;
     end;
     closefile(file1);

     if kind=0 then begin
        for i:=0 to CurrentNode.Count-1 do begin
            savemenu(CurrentNode.Item[i]);
        end;
     end;
   end;
end;

procedure ScanMenu(node:ttreenode;current:string);
var file1:textfile;
    kind:integer;
    index,name:string;
    tmpp:pnodedata;
    tmpnode:ttreenode;
    finddata:twin32finddata;
    tmphandle:integer;
    afile:tstringlist;
    i:integer;
    tmpadmin:padminlist;
begin
     if fileexists(current+'\menu.dat') then begin
        assignfile(file1,current+'\menu.dat');
        reset(file1);
        readln(file1,kind);
        readln(file1,index);
        readln(file1,name);
        closefile(file1);
        tmpnode:=form1.treeview1.Items.AddChild(node,name);
        new(tmpp);
        fillchar(tmpp^,sizeof(tmpp^),0);
        tmpp^.dir:=current;
        tmpp^.kind:=kind;
        tmpp^.name:=name;
        tmpp^.index:=index;
        tmpp^.adminlist.next:=nil;
        tmpnode.data:=tmpp;
        try
           afile:=tstringlist.creatE;
           afile.LoadFromFile(current+'\admin.cfg');
           for i:=0 to afile.Count-1 do
               if afile[i]<>'' then begin
                  new(tmpadmin);
                  tmpadmin.id:=afile[i];
                  tmpadmin.next:=tmpp^.AdminList.next;
                  tmpp^.adminlist.next:=tmpadmin;
               end;
           afile.destroy;
        except
           afile.destroy;        
        end;
        if kind=0 then begin
           tmphandle:=findfirstfile(pchar(current+'\*.*'),finddata);
           while (tmphandle>-1) do begin
                 if finddata.dwfileattributes=file_attribute_directory then begin
                    if (string(finddata.cFilename)<>'.') and
                      (string(finddata.cFileName)<>'..') then
                       Scanmenu(tmpnode,current+'\'+finddata.cFileName);
                 end;

                 if not findnextfile(tmphandle,finddata) then
                     tmphandle:=-1;
           end;
        end;
     end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var file1:textfile;
begin
     TopMenuDir:=ExtractFilePath(application.exename)+'menu';
     if not fileexists(TopMenuDir+'\menu.dat') then begin
        createdirectory(pchar(ExtractFilePath(application.exename)+'menu'),nil);
        assignfile(file1,TopMenuDir+'\menu.dat');
        rewrite(file1);
        writeln(file1,'0');
        writeln(file1,'top');
        writeln(file1,'초기화면');
        closefile(file1);
     end;
     ScanMenu(nil,topmenudir);
     TreeView1.Items.Item[0].Expand(true);
end;

procedure TForm1.nEraseClick(Sender: TObject);
begin
     button3.click;
end;

procedure TForm1.Button1Click(Sender: TObject);
var pos:padminlist;
    tmp:ttreenode;
begin
     form2.ListBox1.clear;
     form2.Memo1.clear;
     tmp:=selectednode;
     pos:=pnodedata(tmp.data)^.adminlist.next;
     while(tmp<>nil) do begin
       if pos=nil then begin
          tmp:=tmp.parent;
          if tmp<>nil then
            pos:=pnodedata(tmp.data)^.adminlist.next;
       end else begin
           form2.memo1.lines.add(pos.id);
           pos:=pos.next;
       end;
     end;

     form2.Edit3.enabled:=true;
     form2.caption:='ADD';
     form2.Edit1.text:='';
     form2.Edit2.text:='';
     form2.Edit3.text:='';
     form2.ComboBox1.Text:='';
     Form1.enabled:=false;
     Form2.Show;
end;


procedure TForm1.FormShow(Sender: TObject);
begin
     //TopMenuDir);
end;

procedure TForm1.Button2Click(Sender: TObject);
var pos:padminlist;
    tmp:ttreenode;
begin
     form2.Memo1.clear;
     form2.ListBox1.clear;
     tmp:=selectednode;
     pos:=pnodedata(tmp.data)^.adminlist.next;
      while(tmp<>nil) do begin
       if pos=nil then begin
          tmp:=tmp.parent;
          if tmp<>nil then  pos:=pnodedata(tmp.data)^.adminlist.next;
       end else begin
           if tmp=selectednode then
              form2.listbox1.Items.Add(pos.id)
           else
              form2.memo1.lines.add(pos.id);
           pos:=pos.next;
       end;
     end;

     form2.caption:='EDIT';
     with tnodedata(SelectedNode.Data^) do begin
          form2.ComboBox1.Text:=form2.ComboBox1.Items[kind];
          form2.Edit3.enabled:=false;
          Form2.Edit1.Text:=Index;
          Form2.Edit2.Text:=Name;
          Form2.Edit3.Text:=extractfilename(Dir);
     end;
     Form1.enabled:=false;
     Form2.Show;
end;


procedure TForm1.TreeView1Change(Sender: TObject; Node: TTreeNode);
begin
     selectedNode:=Node;
     with PNodeData(SelectedNode.Data)^ do begin
       Label1.caption:='종류 : ';
       case kind of
            0:Label1.Caption:=Label1.Caption+'엄마메뉴';
            1:Label1.Caption:=Label1.Caption+'게시판';
            2:Label1.Caption:=Label1.Caption+'채팅방';
            3:Label1.Caption:=Label1.Caption+'편지읽기';
            4:Label1.Caption:=Label1.Caption+'편지쓰기';
            5:Label1.Caption:=Label1.Caption+'개인정보변경';
            6:Label1.Caption:=Label1.Caption+'관리자게시판';
            7:Label1.Caption:=Label1.Caption+'익명게시판';
       end;
       Label2.caption:='인덱스   : '+Index;
       Label3.caption:='이름     : '+Name;
       Label4.caption:='선택번호 : '+extractfilename(Dir);
     end;

     if PNodeData(SelectedNode.Data)^.Kind=0 then begin
        Button1.Enabled:=true;
        nAdd.enabled:=true;
     end else begin
        nAdd.Enabled:=false;
        Button1.Enabled:=false;
     end;
     if SelectedNode.Parent<>nil then begin
        nErase.Enabled:=true;
        Button3.Enabled:=true;
     end else begin
        nErase.Enabled:=false;
        Button3.Enabled:=false;
     end;

end;

procedure TForm1.Button3Click(Sender: TObject);
begin
    dispose(SelectedNode.Data);
    SelectedNode.Destroy;
end;

procedure TForm1.APPEND1Click(Sender: TObject);
begin
     Button1.Click;
end;

procedure TForm1.nEditClick(Sender: TObject);
begin
     Button2.Click;
end;

procedure TForm1.TreeView1Edited(Sender: TObject; Node: TTreeNode;
  var S: String);
begin
     tnodedata(Node.data^).Name:=S;
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin

     form1.close;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var tmp:integer;
begin
     tmp:=MessageDlg(' 저장하고 종료할까요? ',mtConfirmation,mbYesNoCancel,0);
     case tmp of
          mrYes: begin
                      savemenu(TreeView1.Items.Item[0]);
                 end;
          mrNo: ;
          mrCancel: CanClose:=false;
     end;

end;

procedure TForm1.SaveClick(Sender: TObject);
begin
     savemenu(TreeView1.Items.Item[0]);
end;

procedure TForm1.Load1Click(Sender: TObject);
begin
     treeview1.Items.Item[0].Destroy;
     Scanmenu(nil,TopMenuDir);
     TreeView1.Items.Item[0].Expand(true);     
end;

procedure TForm1.About1Click(Sender: TObject);
begin
     aboutbox.showmodal;
end;

end.
