unit httpcont;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
         THTTP= class(TThread)
                       Next:THTTP;
                       Prov:THttp;
                       prechar:char;
                       ignore:integer;
                       BufferStr: String;
                       sockid : integer;
                       procedure Execute; override;
                       destructor Destroy; override;
                       procedure Cmdinput(var tmp1,tmp2,tmp3:string;a:boolean);
                       function Input:string;
                       procedure SendMsg(SrcString:string);
                       function ReadMsg:string;
                private
                public
                      property SendStr:string write SendMsg;
                      property RecvStr:string Read ReadMsg;
         end;

  THTTPFORM = class(TForm)
    Timer1: TTimer;
    procedure closesock;
    procedure WndProc(var Message:TMessage); override;
    procedure init;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HTTPFORM: THTTPFORM;
  head: THTTP;
  loginhtml: tstringlist;

implementation
USES WINSOCK,SOCKET,declare, MainUnit,log;
var
    Http_Socket_ID:integer;
    Http_MyAddr:TSockAddr;

function hextodigit(src:string):integer;
var i:integer;
    sum:integer;
    gop:integer;
begin
     gop:=1;
     src:=uppercase(src);
     sum:=0;
     for i:=length(src) downto 1 do begin
         if src[i]<'A' then begin
            sum:=sum+(strtoint(src[i])*gop);
         end else begin
            sum:=sum+((ord(src[i])-55)*gop);
         end;
         gop:=gop*16;
     end;
     hextodigit:=sum;
end;

function httptonormal(src:string):string;
var tmp:string;
    i:integer;
begin
     i:=1;
           while i<=length(src) do begin
             if src[i]='%' then begin
               tmp:=tmp+chr(hextodigit(src[i+1]+src[i+2]));
               i:=i+3;
             end else begin
               tmp:=tmp+src[i];
               i:=i+1;
             end;
           end;
     httptonormal:=tmp;
end;

procedure THttp.Execute;
var t1,t2,t3:string;
    getfile:string;
    ot2,posting:string;
    id,pass,buffer:string;
    i:integer;
    tmpt:tstringlist;
    stream:tfilestream;
    filebuffer:pointer;
    st:tstringlist;
    tmphandle:integer;
    finddata:twin32finddata;
    tmpstr:string;
    tmpstrlist:tstringlist;
begin
     cmdinput(t1,t2,t3,false);
     if (t1<>'get') and (t1<>'post') then begin
        destroy;
        exit;
     end;

     repeat
     until input='';
     if t1='get' then begin
        t2:=lowercase(t2);
        if t2='/logo1.jpg' then begin
          SendStr:='HTTP 200 Document follows'+CRLF+
          'Server: SpecialWEBBBS'+CRLF;
          sendstr:='Content-type: image/jpeg'+crlf;
          sendstr:='Content-length: '+inttostr(imgLogo1.size)+crlf+crlf;
          send(sockid,imgLogo1.data^,imglogo1.size,0);
          destroy;
          exit;
        end;
        if t2='/logo2.jpg' then begin
          SendStr:='HTTP 200 Document follows'+CRLF+
          'Server: SpecialWEBBBS'+CRLF;
          sendstr:='Content-type: image/jpeg'+crlf;
          sendstr:='Content-length: '+inttostr(imgLogo2.size)+crlf+crlf;
          send(sockid,imgLogo2.data^,imglogo2.size,0);
          destroy;
          exit;
        end;
        ot2:=t2;
        while pos('/',t2)>0 do
              t2[pos('/',t2)]:='\';

                if (copy(t2,2,8)='userdata') or (pos('..',t2)>0) then begin
                   sendstr:=crlf+crlf+' unable to access!';
                   free;
                   exit;
                end;
                if (copy(t2,2,8)='!@#$%^&*') then
                   t2:='\userdata'+copy(t2,10,40);
                while pos('!@',t2)>0 do
                      t2:=copy(t2,1,pos('!@',t2)-1)+'..'+copy(t2,pos('!@',t2)+2,100);

        if fileexists(exedir+'html\'+copy(t2,2,length(t2)-1)) then begin
          SendStr:='HTTP 200 Document follows'+CRLF+
          'Server: SpecialWEBBBS'+CRLF;
          try
            if copy(t2,length(lowercase(t2))-2,3)='txt' then begin
               sendstr:='Content-type: texta/html'+crlf+crlf+'<html>';
               tmpstrlist:=tstringlist.create;
               tmpstrlist.LoadFromFile(exedir+'html\'+copy(t2,2,length(t2)-1));
               for i:=0 to tmpstrlist.count-1 do begin
                   buffer:=buffer+tmpstrlist.Strings[i]+'<br>'
               end;
               buffer:=buffer+crlf+'</html>';
               send(sockid,buffer[1],length(buffer),0);
            end else begin
                sendstr:='Content-type: binary/unknown'+crlf;
                stream:=tfilestream.Create(exedir+'html\'+copy(t2,2,length(t2)-1),0);
                sendstr:='Content-length: '+inttostr(stream.size)+crlf+crlf;
                getmem(filebuffer,stream.size);
                stream.Read(filebuffer^,stream.size);
                send(sockid,filebuffer^,stream.size,0);
                stream.Destroy;
                freemem(filebuffer);
                destroy;
                exit;
            end;
         except
         end;
        end else begin
            SendStr:='HTTP 200 Document follows'+CRLF+
            'Server: SpecialWEBBBS'+CRLF;
            if t2='\' then begin
              try
                sendstr:='Content-type: text/html'+crlf+crlf+'<HTML>';
                tmpt:=tstringlist.create;
                if fileexists(exedir+'html\index.htm') then
                   tmpt.LoadFromFile(exedir+'html\index.htm');
                if fileexists(exedir+'html\index.html') then
                   tmpt.LoadFromFile(exedir+'html\index.html');
                SENDSTR:=tmpt.text;
                tmpt.destroy;
              except
              end;
              sendstr:=string(pchar(tplogo.data));
            end else begin
              sendstr:='Content-type: text/html'+crlf+crlf+'<HTML>';
                if fileexists(exedir+copy(t2,2,length(t2)-1)+'menu.dat') then begin
                   st:=tstringlist.create;
                   st.loadfromfile((exedir+copy(t2,2,length(t2)-1)+'menu.dat'));
                   try
                   if strtoint(st[0]) > 1 then begin
                      sendstr:='지원되지 않습니다. 죄송합니다. <br><br>'+string(pchar(tpLogo.data));
                      destroy;
                      exit;
                   end;
                   except
                   end;
                   sendstr:='<br><br><br>';

                   if st[0]='0' then begin
                      if fileexists(exedir+copy(t2,2,length(t2)-1)+'menu.htm') then begin
                         st.loadfromfile((exedir+copy(t2,2,length(t2)-1)+'menu.htm'));
                         sendstr:=st.text;
                      end else begin
                          tmphandle:=findfirstfile(pchar(exedir+copy(t2,2,length(t2)-1)+'*.*'),finddata);
                          while (tmphandle>-1) do begin
                                if finddata.dwfileattributes=file_attribute_directory then begin
                                if (string(finddata.cFilename)<>'.') and
                                   (string(finddata.cFileName)<>'..') then begin
                                   if fileexists(exedir+copy(t2,2,length(t2)-1)+finddata.cFileName+'\menu.dat') then
                                      sendstr:='<A href="'+Finddata.cFileName+'/">';
                                     try
                                      st.loadfromfile((exedir+copy(t2,2,length(t2)-1)+findData.cFileName+'\menu.dat'));
                                      sendstr:=finddata.cFileName+'. '+st[2]+'</A> <BR>'+CRLF;
                                     except
                                     end;
                                end;
                          end;
                          if not findnextfile(tmphandle,finddata) then
                             tmphandle:=-1;
                          end;
                      end;
                      sendstr:=string(pchar(tpLogo.data));
                      destroy;
                      exit;
                   end;
                   if st[0]='1' then begin
                      sendstr:='<body><p Align="center"><H1>게시판</H1><BR><BR>';
                      //sendstr:='<A href="'+copy(ot2,1,length(ot2)-1)+'">'+'상위 메뉴로..'+'</A><BR><BR>'+CRLF+TMPSTR;
                      i:=1;
                      TMPSTr:='';
                      while(fileexists(exedir+copy(t2,2,length(t2)-1)+inttostr(i)+'.txt')) do begin
                        st.loadfromfile(exedir+copy(t2,2,length(t2)-1)+inttostr(i)+'.txt');
//copy(t2,2,length(t2)-1)+
                        tmpstr:='<P>'+inttostr(i)+'.<A href="'+ot2+inttostr(i)+'.txt">'+st[1]+'</A>, by '+st[2]+'('+st[3]+') <BR></P>'+CRLF+TMPSTR;
                        inc(i);
                      end;
                      sendstr:=tmpstr;
                      sendstr:='<BR><BR>'+string(pchar(tplogo.data));
                   end;
                   destroy;
                   exit;
                   st.free;
                end;
            end;
        end;
     end;
     if t1='post' then begin
         posting:=input;
         buffer:='';
         if t2='/login' then begin
           i:=1;
           id:=copy(posting,pos('=',posting)+1,pos('&',posting)-pos('=',posting)-1);
           pass:=copy(posting,pos('&',posting)+1,length(posting)-pos('&',posting));
           pass:=copy(pass,pos('=',pass)+1,length(pass)-pos('=',pass)+1);
           id:=httptonormal(id);
           pass:=httptonormal(pass);
           if (lowercase(id)='guest') or
              (id='손님') then begin
                          sendstr:='죄송합니다. 아직 지원되지 않습니다.<br><br>'+string(pchar(tplogo.data));
                          destroy;
                          exit;

           end;
           sendstr:='<HEAD><META HTTP-EQUIV="refresh" CONTENT="0; url=menu/"></HEAD>';
           destroy;
           exit;

        end;
     end;
     SENDSTR:='</HTML>';
     destroy;
end;

destructor THttp.Destroy;
begin
     self.Prov.next:=self.Next;
     if self.next<>nil then Self.Next.Prov:=Self.Prov;
     closesocket(SockID);
     inherited;
end;

procedure THTTPFORM.WndProc(var Message:TMessage);
var TempClient: TSockAddr;
    TmpSize:integer;
    Tmpsockid:integer;
    tmphttp:THTTP;
begin
     case Message.Msg of
          wm_user:
            case wsagetselectevent(Message.LParam) of
                 fD_read:;
                 fd_write:;
                 fd_accept: begin
                           tmpsize:=sizeof(tempclient);
                           tmpsockid:=winsock.accept(HTTP_Socket_ID,@TempClient,@tmpsize);
                           tmphttp:= thttp.Create(true);
                           tmphttp.prov:=head;
                           tmphttp.next:=head.Next;
                           if tmphttp.next<>nil then
                              tmphttp.next.prov:=tmphttp;
                           head.next:=tmphttp;
                           tmphttp.sockid:=tmpsockid;
                           tmphttp.priority:=tplowest;
                           tmphttp.Resume;
                 end;
                 fd_close: begin
//                           deleteuser(message.wparam);
                 end;
            end;
     end;

     inherited;
     //
end;

function THTTP.ReadMsg:string;
var tmp:array[1..4096] of char;
    i:integer;
    tmps:string;
    tmpn:integer;
begin
     tmpn:=recv(sockid,tmp[1],4000,0);
     if tmpn=0 then begin
        free;
        exit;
     end;
     for i:=1 to tmpn do begin
         if ignore>0 then begin
            dec(ignore);
            continue;
         end;
         if tmp[i]=chr(10) then tmp[i]:=chr(13);
         if (prechar=tmp[i]) and (tmp[i]=chr(13)) then begin
            prechar:=chr(0);
            continue;
         end;
         prechar:=tmp[i];
         if tmp[i]=chr(0) then continue;
         tmps:=tmps+tmp[i];
     end;
     readmsg:=tmps;
end;


function THTTP.Input:String;
var i:integer;
begin
     repeat
           bufferstr:=bufferstr+readmsg;
           for i:=1 to length(Bufferstr) do
               if ord(Bufferstr[i])=13 then begin
                  if i>1 then
                     Input:=copy(Bufferstr,1,i-1)
                  else
                      input:='';
                  if i<length(Bufferstr) then
                     Bufferstr:=copy(Bufferstr,i+1,length(Bufferstr)-i)
                  else
                      bufferstr:='';
                  exit;
               end;
               if suspended=false then suspend;
     until terminated;
end;

procedure THTTP.SendMsg(SrcString: string);
begin
     send(sockid,srcstring[1],length(Srcstring),0);
//        free;
end;
procedure THTTP.CmdInput(var tmp1,tmp2,tmp3:string;a:boolean);
begin
     tmp1:=input+' ';
     tmp2:='';
     tmp3:='';
     tmp2:=copy(tmp1,pos(' ',Tmp1)+1,length(tmp1)-pos(' ',tmp1));
     tmp1:=copy(tmp1,1,pos(' ',Tmp1)-1);
     tmp3:=copy(tmp2,pos(' ',Tmp2)+1, length(tmp2)-pos(' ',tmp2)-1);
     tmp2:=copy(tmp2,1,pos(' ',Tmp2)-1);
     if not a then tmp1:=lowercase(tmp1);
end;

{$R *.DFM}

procedure THTTPFORM.closesock;
begin
     closesocket(http_socket_id);
end;

procedure THTTPFORM.init;
begin
// http activity
     Http_Socket_ID:=winsock.socket(pf_inet,sock_stream,ipproto_tcp);
     if Http_Socket_ID<0 then
        Raise Exception.Create('Failed: Getting Socket ID');
     Http_MyAddr.sin_family:=af_inet;
     Http_MyAddr.Sin_Port:=htons(httpport);
     Http_MyAddr.sin_addr.s_addr:=inaddr_any;
     if Bind(Http_Socket_ID,Http_MyAddr,sizeof(Http_MyAddr))<0 then
        Raise Exception.Create('Failed: Binding');
     if Listen(Http_Socket_ID, 10)<0 then
        Raise Exception.Create('Failed: listening');
     Winsock.WSAAsyncSelect(Http_Socket_ID,HTTPFORM.Handle, WM_User, FD_Accept);
end;

procedure THTTPFORM.Timer1Timer(Sender: TObject);
var t:thttp;
begin
     t:=head.next;
     while t<>nil do begin
           t.Resume;
           t:=t.next;
     end;
end;

procedure THTTPFORM.FormCreate(Sender: TObject);
begin
     head:=thttp.create(true);
end;

end.
