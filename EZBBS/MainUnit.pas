unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Socket, Menus, ExtCtrls, Db, DBTables, ComCtrls, StdCtrls,mmsystem,shellapi,about,
  ToolWin, Buttons;

//const
   // clbtnface=16757940;
type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    Timer1: TTimer;
    F1: TMenuItem;
    N3: TMenuItem;
    N5: TMenuItem;
    R2: TMenuItem;
    N6: TMenuItem;
    S1: TMenuItem;
    U1: TMenuItem;
    M1: TMenuItem;
    N7: TMenuItem;
    X1: TMenuItem;
    N8: TMenuItem;
    E1: TMenuItem;
    StatusBar1: TStatusBar;
    A1: TMenuItem;
    N1: TMenuItem;
    AboutA1: TMenuItem;
    N2: TMenuItem;
    L1: TMenuItem;
    Timer2: TTimer;
    ListView1: TListView;
    PopupCurrentUser: TPopupMenu;
    N4: TMenuItem;
    N9: TMenuItem;
    CoolBar1: TCoolBar;
    OffBtn: TSpeedButton;
    LogBtn: TSpeedButton;
    MsgBtn: TSpeedButton;
    AllMsgBtn: TSpeedButton;
    DisConn: TSpeedButton;
    UserEditor: TSpeedButton;
    MenuEditor: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure LoadResources;
    procedure MnuViewConClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure wndproc( var Message : TMessage ); override;
    procedure N1Click(Sender: TObject);
    procedure S1Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure R2Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure E1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure X1Click(Sender: TObject);
    procedure BBsHide(Sender: TObject);
    procedure A1Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure M1Click(Sender: TObject);
    procedure AboutA1Click(Sender: TObject);
    procedure L1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer2Timer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure OffBtnClick(Sender: TObject);
    procedure LogBtnClick(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure ListView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuEditorClick(Sender: TObject);
    procedure MsgBtnClick(Sender: TObject);
    procedure AllMsgBtnClick(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure DisConnClick(Sender: TObject);
    procedure ListView1Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure ListView1Deletion(Sender: TObject; Item: TListItem);
    procedure UserEditorClick(Sender: TObject);
    procedure U1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
{$R WEB.RES}
{$R VOICE.RES}

var
  CONNECTUSERLIST : TLISTVIEW;
  ALLUSERLIST : TLISTVIEW;

  MainForm: TMainForm;
  IconData : TNotifyIconData;
  mini:boolean;
    
procedure PlayVoice(VoiceName:string);

implementation
uses declare, httpcont, sockset, envior, Splash, Log,client;
{$R *.DFM}
procedure LoadaResource(var src:TData;name,kind:string); forward;

procedure TMainForm.WndProc;
begin
 case Message.Msg of
  WM_USER + 1: case Message.lParam of
                WM_LBUTTONDOWN: begin
                               ShowWindow ( Application.Handle, SW_NORMAL);
                               SetForegroundwindow(application.handle);
//                               mainform.show;
//                               Mainform.show;
//                               ShowWindow ( Mainform.Handle, SW_SHOW);

                end;
               end;
 end;
 inherited;
end;

procedure PlayVoice(VoiceName:string);
var
  hResource : HGLOBAL;
  pszSound  : LPCSTR;
begin
{ if not speech then exit;
  hResource := LoadResource ( hInstance,
               FindResource ( hInstance, pchar(VoiceName), 'WAVE' ) );
  pszSound  := LockResource ( hResource );
  playSound ( pszSound, mainform.HANDLE, SND_MEMORY );
  FreeResource ( hResource );}
end;

function ScanMenu(node:tmytreenode;current:string;var indexptr:pindex):TMyTreeNode;
var file1:textfile;
    kind:integer;
    index,name,date,count,title,time,pages,id:string;
    tmpnode:tmytreenode;
    finddata:twin32finddata;
    tmphandle:integer;
    tmpindex:pindex;
    canread:string;
    i:integer;
    afile:tstringlist;
begin
     tmpnode:=nil;
     if fileexists(current+'\menu.dat') then begin
        try
          fsplash.progress.caption:='loading .. '+current;
          application.processmessages;
        except
        end;

        assignfile(file1,current+'\menu.dat');
        reset(file1);
        readln(file1,kind);
        readln(file1,index);
        readln(file1,name);
        closefile(file1);
        new(tmpindex);
        tmpnode:=node.addchild;
        tmpindex.next:=nil;
        tmpindex.menu:=tmpnode;
        indexptr.next:=tmpindex;
        indexptr:=tmpindex;
        tmpnode.name:=name;
        tmpnode.dir:=uppercase(current);
        tmpnode.choiceindex:=lowercase(extractfilename(current));
        tmpnode.kind:=kind;
        tmpnode.index:=uppercase(index);

        afile:=tstringlist.create;
        try
           tmpnode.adminlist.next:=nil;
           afile.LoadFromFile(current+'\admin.cfg');
           for i:=0 to afile.Count-1 do
               if afile[i]<>'' then begin
                  tmpnode.addtoadmin(afile[i]);
               end;
        except
        end;
        afile.destroy;
{        if fileexists(current+'\menu.txt') then begin
                tmpnode.menutxt:=TStringlist.Create;
                tmpnode.menutxt.loadFromFile(current+'\menu.txt');
        end;
        if fileexists(current+'\premenu.txt') then begin
                tmpnode.premenutxt:=TStringlist.Create;
                tmpnode.PreMenuTxt.LoadFromFile(current+'\premenu.txt');
        end;}

        if kind=2 then begin
           tmpnode.Chat:=TChatRoom.create;
        end;
        if (kind=1) or ((kind=6) or (kind=7)) then begin
           tmpnode.Board:=TBoard.Create;
           tmpnode.Board.Time:=TStringlist.Create;
           tmpnode.Board.IndexByID:=TStringlist.Create;
           tmpnode.Board.Pages:=TStringlist.Create;
           tmpnode.Board.CanAccess:=TStringlist.Create;
           tmpnode.Board.IndexByTitle:=TStringlist.Create;
           tmpnode.Board.Date:=TStringlist.Create;
           tmpnode.Board.count:=TStringlist.Create;
           tmpnode.Board.name:=TStringlist.Create;
           i:=1;
           while(fileexists(current+'\'+inttostr(i)+'.txt')) do begin
             assignfile(file1,current+'\'+inttostr(i)+'.txt');
             reset(file1);
             readln(file1,canread);
             readln(file1,title);
             readln(file1,id);
             readln(file1,name);
             readln(file1,date);
             readln(file1,time);
             readln(file1,count);
             readln(file1,pages);
             closefile(file1);
             tmpnode.board.IndexByID.Add(id);
             tmpnode.board.IndexByTitle.Add(title);
             tmpnode.board.CanAccess.Add(canread);
             tmpnode.board.Date.Add(date);
             tmpnode.board.Name.Add(name);
             tmpnode.board.Time.Add(time);
             tmpnode.board.Count.Add(count);
             tmpnode.board.Pages.Add(pages);
             inc(i);
           end;
        end;
        if kind=0 then begin
           tmphandle:=findfirstfile(pchar(current+'\*.*'),finddata);
           while (tmphandle>-1) do begin
                 if finddata.dwfileattributes=file_attribute_directory then begin
                    if (string(finddata.cFilename)<>'.') and
                      (string(finddata.cFileName)<>'..') then begin
                       Scanmenu(tmpnode,current+'\'+finddata.cFileName,indexptr);
                      end;
                 end else begin
                     setfileattributes(pchar(current+'\'+finddata.cFilename),FILE_ATTRIBUTE_NORMAL);
                 end;
                 if not findnextfile(tmphandle,finddata) then
                     tmphandle:=-1;
           end;
           tmpnode.SortChildrenByChoiceIndex;
        end;
     end;

     scanmenu:=tmpnode;
end;

procedure TMainForm.FormShow(Sender: TObject);
var tmphandle:integer;
    lpVersionInfo : TOSVersionInfo;
    file1:textfile;
    tmpindex:pindex;
    i:integer;
    config:tstringlist;

begin
 //
  exedir:=extractfilepath(application.exename);

  application.ProcessMessages;

  PLAYVOICE('START');
  fsplash.progress.caption:='loading configuraitons ';

  application.ProcessMessages;
  config:=tstringlist.create;
  try
     config.loadfromfile(exedir+'port.cfg');
     telnetport:=strtoint(config[0]);
     httpport:=strtoint(config[1]);
  except
  end;
  try
     config.loadfromfile(exedir+'bbsname.cfg');
     bbsname:=config[0];
  except
  end;
  try
     config.loadfromfile(exedir+'logonmsg.cfg');
     loginmessage:=config.text;
  except
  end;
  try
     config.loadfromfile(exedir+'etc.cfg');
     if config[0]='N' then
        runbind:=FALSE
     else
         runbind:=TRUE;

     if config[1]='N' then
        RunHide:=FALSE
     else
         RunHide:=TRUE;

     if config[2]='N' then
        IsFree:=FALSE
     else
         IsFree:=TRUE;

     if config[3]='N' then
        MultiLogin:=FALSE
     else
         MultiLogin:=TRUE;
  except
  end;

  emotion:=tstringlist.create;

  try
     emotion.loadfromfile(exedir+'emotions.cfg');
  except
  end;

  config.destroy;

  PLAYVOICE('loading');
  application.ProcessMessages;
  fsplash.progress.caption:='creating directories... ';
  application.processmessages;
  CreateDirectory(pchar(exedir+'html'),nil);
  CreateDirectory(pchar(exedir+'mail'),nil);
  CreateDirectory(pchar(exedir+'UserData'),nil);
//  CreateDirectory(pchar(exedir+'UserData\regnum'),nil);
  CreateDirectory(pchar(exedir+'log'),nil);

  tmphandle:=createfile(pchar(ExeDir+'userdata\손님.ID'),generic_write,0,nil,CREATE_NEW,FILE_ATTRIBUTE_NORMAL,0);
  if TmpHandle>-1 then
       closehandle(tmphandle);

  tmphandle:=createfile(pchar(ExeDir+'userdata\guest.ID'),generic_write,0,nil,CREATE_NEW,FILE_ATTRIBUTE_NORMAL,0);
  if TmpHandle>-1 then
       closehandle(tmphandle);

  lpVersionInfo.dwOSVersionInfoSize := SizeOf ( TOSVersionInfo );
  GetVersionEx ( lpVersionInfo );
  case lpVersionInfo.dwPlatformID of
       VER_PLATFORM_WIN32s:WindowsVersion:='Win3.1 ';
       VER_PLATFORM_WIN32_WINDOWS:WindowsVersion:='Win95 ';
       VER_PLATFORM_WIN32_NT:WindowsVersion:='WinNT ';
  end;
  with lpVersionInfo do
       WindowsVersion:=WindowsVersion+inttostr(dwMajorversion)+'.'+inttostR(dwMinorVersion)+' Build '+inttostr(loword(dwBuildNumber));

  if not fileexists(exedir+'menu\menu.dat') then begin
      fsplash.progress.caption:='creating top menu... ';
      application.processmessages;

      createdirectory(pchar(ExtractFilePath(application.exename)+'menu'),nil);
      assignfile(file1,exedir+'menu\menu.dat');
      rewrite(file1);
      writeln(file1,'0');
      writeln(file1,'top');
      writeln(file1,'초기화면');
      closefile(file1);
   end;
   new(HeadIndex);
   tmpindex:=headindex;
   TopNode:=ScanMenu(nil,exedir+'menu',tmpIndex);
   for i:=1 to MaxUser do
       userlist[i]:=nil;
   fsplash.progress.caption:='loading resources... ';
   application.processmessages;
   loadresources;
   fsplash.progress.caption:='socket init... ';
   application.processmessages;

  with IconData do
    begin
      cbSize           := SizeOf ( IconData );
      Wnd              := mainform.Handle;
      uID              := 100;
      uFlags           := NIF_MESSAGE + NIF_ICON + NIF_TIP;
      uCallbackMessage := WM_USER + 1;
      hIcon            := Application.Icon.Handle;
      szTip            := 'EASYBBS Builder';
    end;

   logwrite(' 로딩 완료 ');
   if runbind then begin
      r2.click;
      if runhide then mini:=true else mini:=false;
   end;
   application.onminimize:=bbshide;
   timer2.enabled:=true;
end;

procedure TMainForm.BBSHIDE(Sender: TObject);
begin
     ShowWindow ( Application.Handle, SW_HIDE);
//     mainform.hide;
//
end;

procedure TMainForm.MnuViewConClick(Sender: TObject);
begin
//     MnuViewCon.Checked:= not MnuViewCon.Checked;
//     if MnuViewCon.Checked then
//     else
//        FrmConnection.Hide;

end;

procedure TMainForm.Timer1Timer(Sender: TObject);
var i:integer;
begin

     for i:=1 to MaxUser do begin
       try
         if assigned(userlist[i]) then
            if Userlist[i].suspended then begin
//               TUser(userlist[i]).recievemsg('a','b','c');
               Userlist[i].resume;

            end;
       except
       end;
     end;
//     deleteuser;
end;

procedure TMainForm.N1Click(Sender: TObject);
begin
        FrmConnection.Show
end;

procedure TMainForm.S1Click(Sender: TObject);
begin
     PLAYVOICE('stop');
     s1.checked:=true;
     n5.checked:=false;
     r2.checked:=false;
     closeall;
     closesock;
     httpform.closesock;
     httpform.Timer1.enabled:=false;
     logwrite(' 정지됨 ');
     timer1.enabled:=false;
end;

procedure TMainForm.N5Click(Sender: TObject);
begin
  try
     if S1.checked then begin
        socket_init;
        httpform.init;
        logwrite(' 바인딩 성공 ');
     end;
     s1.checked:=false;
     n5.checked:=true;
     r2.checked:=false;
     httpform.Timer1.enabled:=true;
     Timer1.enabled:=true;
  except
      logwrite(' 바인딩 실패 ');
        MessageBox(Handle,' telnet또는 http포트를 다른 프로그램이 점유하고 있습니다.','오류',0);
        S1.click;
  end;
end;

procedure TMainForm.R2Click(Sender: TObject);
begin
  try
     if S1.checked then begin
        socket_init;
        httpform.init;
     end;
     PLAYVOICE('startdo');
     s1.checked:=false;
     n5.checked:=false;
     r2.checked:=true;
     httpform.Timer1.enabled:=true;
     Timer1.enabled:=true;
     logwrite(' 바인딩 성공 - 정상작동 시작 ');
  except
        MessageBox(Handle,' telnet또는 http포트를 다른 프로그램이 점유하고 있습니다.','오류',0);
        logwrite(' 작동 실패 ');
        S1.click;
  end;
end;

procedure TMainForm.N8Click(Sender: TObject);
var socketsetup:TSocketSetup;
begin
  socketsetup:=TSocketSetup.Create(self);
  socketsetup.showmodal;
  socketsetup.Destroy;
end;

procedure TMainForm.E1Click(Sender: TObject);
var enviorsetup:TenviorSet;
begin
  enviorsetup:=TenviorSet.Create(self);
  enviorsetup.showmodal;
  enviorsetup.Destroy;
end;
procedure LoadaResource(var src:tdata;name,kind:string);
var Res:TResourceStream;
    buffer:tmemorystream;
//    tmp:pointer;
begin
     Res:=TResourceStream.Create(HInstance,Name,pchar(Kind));
     buffer:=TMEmorystream.create;

     buffer.LoadFromStream(res);
     getmem(src.data,buffer.size);
     buffer.Read(src.data^,buffer.Size);
     src.size:=buffer.size;
//     src:=tmp;
     buffer.destroy;
     res.destroy;
end;

procedure TMainform.LoadResources;
begin
     loadaresource(tpGuest,'TPGUEST','HTML');
     loadaresource(tpLogon,'TPLOGON','HTML');
     loadaresource(tpLogo,'TPLOGO','HTML');
     loadaresource(imgLogo1,'LOGO1','IMAGES');
     loadaresource(imgLogo2,'LOGO2','IMAGES');
//
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
     if not s1.checked then begin
        PLAYVOICE('isquit');
        if messagedlg(' 정말 끝내시겠습니까? ',mtConfirmation,[mbYes,mbNo],0)=
           mrNo then begin
           playvoice('cancel');
           canclose:=false;
           exit;
        end;
     end;
     PLAYVOICE('termin');
end;

procedure TMainForm.X1Click(Sender: TObject);
begin
     close;
end;

procedure TMainForm.A1Click(Sender: TObject);
var file1:tstringlist;
begin
     file1:=tstringlist.create;
     file1.add(inttostr(telnetport));
     file1.add(inttostr(httpport));
     file1.savetofile(exedir+'port.cfg');
     file1.clear;
     file1.add(bbsname);
     file1.savetofile(exedir+'bbsname.cfg');
     file1.clear;
     file1.text:=(LoginMessage);
     file1.savetofile(exedir+'logonmsg.cfg');
     FILE1.CLEAR;
     if runbind then
        FILE1.ADD('Y')
     ELSE
         FILE1.ADD('N');
     if RunHide then
        FILE1.ADD('Y')
     ELSE
         FILE1.ADD('N');
     if IsFree then
        FILE1.ADD('Y')
     ELSE
         FILE1.ADD('N');
     if MultiLogin then
        FILE1.ADD('Y')
     ELSE
         FILE1.ADD('N');
     file1.savetofile(exedir+'ETC.cfg');
     file1.destroy;
end;

procedure TMainForm.Image1Click(Sender: TObject);
begin
//     shellexecute(handle,'open','http://video-q.com',nil,nil,sw_shownormal);
end;

procedure TMainForm.M1Click(Sender: TObject);
begin
     shellexecute(handle,'open','menueditor.exe',nil,pchar(exedir),sw_shownormal);
end;

procedure TMainForm.AboutA1Click(Sender: TObject);
var aboutbox:tform;
begin
     aboutbox:=taboutbox.create(Self);
  aboutbox.showmodal;
  aboutbox.destroy;
end;


procedure TMainForm.L1Click(Sender: TObject);
begin
     logform.visible:=not logform.visible;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Shell_NotifyIcon ( NIM_DELETE, @IconData );
//     Shell_NotifyIcon ( NIM_ADD, @iconData );
     logwrite(' terminated. ');
end;

procedure TMainForm.Timer2Timer(Sender: TObject);
begin
     if mini then begin
        application.Minimize;
        mini:=false;
        timer2.interval:=1000;
     end;

   Shell_NotifyIcon ( NIM_ADD, @IconData );
end;


procedure TMainForm.FormResize(Sender: TObject);
begin
     listview1.height:=ClientHeight-Statusbar1.height-CoolBar1.height-2;
     listview1.width:=ClientWidth;
end;

procedure TMainForm.OffBtnClick(Sender: TObject);
begin
 close;
end;

procedure TMainForm.LogBtnClick(Sender: TObject);
begin
     logform.visible:=not logform.visible;
end;

procedure TMainForm.N4Click(Sender: TObject);
begin
     disconn.Click;
end;


procedure TMainForm.ListView1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     if Listview1.selcount>0 then begin
      listview1.popupmenu:=PopupCurrentUser;
      disconn.enabled:=true;
      msgbtn.enabled:=true;
     end else begin
      listview1.popupmenu:=nil;
      disconn.enabled:=false;
      msgbtn.enabled:=false;
     end;
end;


procedure TMainForm.MenuEditorClick(Sender: TObject);
begin
     shellexecute(handle,'open','menueditor.exe',nil,pchar(exedir),sw_shownormal);
end;

procedure TMainForm.MsgBtnClick(Sender: TObject);
var tmpstr:string;
begin
     tmpstr:=inputbox('메세지 입력','보낼 메세지','');
     try
       if listview1.selected<>nil then
          tuser(listview1.Selected.data).Receivemessage('운영자','',tmpstr);
     except
     end;
end;

procedure TMainForm.AllMsgBtnClick(Sender: TObject);
var tmpstr:string;
    i:integer;
begin
     tmpstr:=inputbox('메세지 입력','보낼 메세지','');
     for i:=1 to MaxUser do begin
            try
              tuser(userlist[i]).Receivemessage('운영자','',tmpstr);
            except
            end;
     end;
     end;
procedure TMainForm.N9Click(Sender: TObject);
begin
     MsgBtn.Click;
end;

procedure TMainForm.DisConnClick(Sender: TObject);
begin
     try
       if listview1.selected<>nil then tuser(listview1.Selected.data).free;
     except
     end;
end;

procedure TMainForm.ListView1Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
     if ListView1.Items.Count>0 then
        allmsgbtn.enabled:=true;

     if Listview1.selcount>0 then begin
      listview1.popupmenu:=PopupCurrentUser;
      disconn.enabled:=true;
      msgbtn.enabled:=true;
     end else begin
      listview1.popupmenu:=nil;
      disconn.enabled:=false;
      msgbtn.enabled:=false;
     end;
end;

procedure TMainForm.ListView1Deletion(Sender: TObject; Item: TListItem);
begin
     if ListView1.Items.Count=1 then
        allmsgbtn.enabled:=false;
end;

procedure TMainForm.UserEditorClick(Sender: TObject);
begin
     shellexecute(handle,'open','usereditor.exe',nil,pchar(exedir),sw_shownormal);
end;

procedure TMainForm.U1Click(Sender: TObject);
begin
     usereditor.click;
end;

end.


