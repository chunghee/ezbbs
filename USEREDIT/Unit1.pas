unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolWin, ComCtrls, Menus, Buttons;

type
  puserinfo = ^TUserInfo;
  TUserInfo = record
            passwd:string;
            pf:array[1..3] of string;

  end;
  TUserEdit = class(TForm)
    ListView1: TListView;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    CoolBar1: TCoolBar;
    RefreshBtn: TSpeedButton;
    Delete: TSpeedButton;
    EditBtn: TSpeedButton;
    PopupMenu1: TPopupMenu;
    popupdel: TMenuItem;
    Waiter: TSpeedButton;
    Ok: TSpeedButton;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
    procedure RefreshBtnClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure EditBtnClick(Sender: TObject);
    procedure popupdelClick(Sender: TObject);
    procedure ListView1Changing(Sender: TObject; Item: TListItem;
      Change: TItemChange; var AllowChange: Boolean);
    procedure WaiterClick(Sender: TObject);
    procedure OkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  UserEdit: TUserEdit;

implementation

uses Unit2;

{$R *.DFM}

procedure Rescan;
var tmphandle:integer;
    finddata:twin32finddata;
    current:string;
    usritm:TListItem;
    tmp:tstringlist;
    tusr:PUserInfo;
begin
     useredit.listview1.items.clear;
     current:=extractfilepath(application.exename)+'userdata';
     tmphandle:=findfirstfile(pchar(current+'\*.dat'),finddata);
     tmp:=tstringlist.create;
     while (tmphandle>-1) do begin
       if not fileexists(current+'\'+
        copy(finddata.cfilename,1,length(string(finddata.cfilename))-4)+'.wat') then begin
                usritm:=useredit.listview1.Items.Add;
                usritm.caption:=copy(finddata.cfilename,1,length(string(finddata.cfilename))-4);
                tmp.LoadFromFile(current+'\'+finddata.cfilename);
                usritm.SubItems.Add(tmp[1]);
                usritm.SubItems.Add(tmp[2]);
                usritm.SubItems.Add(tmp[3]);
                usritm.SubItems.Add(tmp[4]);
                usritm.SubItems.Add(tmp[5]);
                usritm.SubItems.Add(tmp[6]);
                usritm.SubItems.Add(tmp[7]);
                usritm.SubItems.Add(tmp[9]);
                usritm.SubItems.Add(tmp[10]);
                usritm.SubItems.Add(tmp[11]);
                usritm.subitems.Add(tmp[0]);
//                usritm.data:=tusr;
        end;
        if not findnextfile(tmphandle,finddata) then
             tmphandle:=-1;
     end;
     tmp.destroy;
end;

procedure Rescan_Waiter;
var tmphandle:integer;
    finddata:twin32finddata;
    current:string;
    usritm:TListItem;
    tmp:tstringlist;
    tusr:PUserInfo;
begin
     useredit.listview1.items.clear;
     current:=extractfilepath(application.exename)+'userdata';
     tmphandle:=findfirstfile(pchar(current+'\*.dat'),finddata);

     tmp:=tstringlist.create;
     while (tmphandle>-1) do begin
//        useredit.caption:=current+'\'+copy(string(finddata.cfilename),1,length(string(finddata.cfilename))-4)+'.wat';
       if fileexists(current+'\'+
        copy(finddata.cfilename,1,length(string(finddata.cfilename))-4)+'.wat') then begin
                usritm:=useredit.listview1.Items.Add;
                usritm.caption:=copy(finddata.cfilename,1,length(string(finddata.cfilename))-4);
                tmp.LoadFromFile(current+'\'+finddata.cfilename);
                usritm.SubItems.Add(tmp[1]);
                usritm.SubItems.Add(tmp[2]);
                usritm.SubItems.Add(tmp[3]);
                usritm.SubItems.Add(tmp[4]);
                usritm.SubItems.Add(tmp[5]);
                usritm.SubItems.Add(tmp[6]);
                usritm.SubItems.Add(tmp[7]);
                usritm.SubItems.Add(tmp[9]);
                usritm.SubItems.Add(tmp[10]);
                usritm.SubItems.Add(tmp[11]);
                usritm.subitems.Add(tmp[0]);
//                usritm.data:=tusr;
        end;
        if not findnextfile(tmphandle,finddata) then
             tmphandle:=-1;
     end;
     tmp.destroy;

end;

procedure TUserEdit.FormResize(Sender: TObject);
begin
     ListView1.Width:=clientwidth;
     ListView1.Height:=ClientHeight-Coolbar1.Height+1;
end;

procedure TUserEdit.FormCreate(Sender: TObject);
begin
rescan;
end;

procedure TUserEdit.ListView1DblClick(Sender: TObject);
begin
     editbtn.click;
//        inputbox('비밀번호 변경','암호를 입력하세요',listview1.selected.subitems[10]);
end;

procedure TUserEdit.RefreshBtnClick(Sender: TObject);
begin
     ok.enabled:=false;
     RESCAN;
end;



procedure TUserEdit.N1Click(Sender: TObject);
begin
     application.terminate;
end;

procedure TUserEdit.DeleteClick(Sender: TObject);
var current:string;
begin
   if listview1.selected=nil then exit;
     try
       current:=extractfilepath(application.exename)+'userdata\';
       if MessageDlg('정말 삭제하시겠습니까?',mtWarning,[mbYes,mbNo],0)=
        mrYes then begin
        if listview1.Selected<>nil then
          deletefile(current+listview1.selected.caption+'.id');
          deletefile(current+listview1.selected.caption+'.dat');
          deletefile(current+listview1.selected.caption+'.wat');          
          listview1.Selected.Destroy;
      end;
     except
     end;
end;

procedure TUserEdit.EditBtnClick(Sender: TObject);
begin

     if listview1.Selected<>nil then begin
        with dataedit do begin
             edit1.text:=listview1.selected.caption;
             edit2.text:=listview1.selected.subitems[0];
             edit3.text:=listview1.selected.subitems[10];
             edit4.text:=listview1.selected.subitems[1];
             edit5.text:=listview1.selected.subitems[2];
             edit6.text:=listview1.selected.subitems[3];
             edit7.text:=listview1.selected.subitems[4];
             edit8.text:=listview1.selected.subitems[5];
             edit9.text:=listview1.selected.subitems[6];
             edit10.text:=listview1.selected.subitems[7];
             edit11.text:=listview1.selected.subitems[8];
             edit12.text:=listview1.selected.subitems[9];
        end;
        dataedit.showmodal;
     end;
end;

procedure TUserEdit.popupdelClick(Sender: TObject);
begin
     delete.click;
end;

procedure TUserEdit.ListView1Changing(Sender: TObject; Item: TListItem;
  Change: TItemChange; var AllowChange: Boolean);
begin
     if Listview1.Selcount>=0 then listview1.popupmenu:=popupmenu1;
end;

procedure TUserEdit.WaiterClick(Sender: TObject);
begin
        ok.enabled:=true;
        rescan_waiter;
end;

procedure TUserEdit.OkClick(Sender: TObject);
var current:string;
begin
   if listview1.selected=nil then exit;
     try
       current:=extractfilepath(application.exename)+'userdata\';
        if listview1.Selected<>nil then
          deletefile(current+listview1.selected.caption+'.wat');
        listview1.Selected.Destroy;
      except
     end;
end;

end.
