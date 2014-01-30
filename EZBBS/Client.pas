unit Client;

interface
uses classes, declare, mmsystem, messages, forms, comctrls;

type
        TTerminalType=(ctTelnet,ctWeb);

         TUser= class(TThread)
                      constructor init(SocketID:integer; IPAddr:integer;ctype:TTerminalType);
                      destructor  Destroy; override;
                      procedure Execute; override;
                       function RECEIVEMessage(from,fromname,text:string):boolean;
                private
                       ulid:integer;
                       MyIP:integer;
                       danger:boolean;
                       BufferStr: String;
                       mypos: TMyTreeNode;
                       Index: string;
                       State: integer;
                       birthdate,ID,tmpID: String;
                       chatname:string[8];
                       pts:integer;
                       SockID: integer;
                       Clienttype:TTerminalType;
                       roomnum: integer;
                       Ignore: integer;
                       prechar:char;
                       MyName:String;
                       echo_star:boolean;
                       provmsg:array[1..12] of string;
                       password:string;
                       lastinputtime:cardinal;
                       sendbeep:boolean;
                       listitem:tlistitem;
                       provchat:array[1..20] of string;
                       procedure Profile(id:string);
                       procedure SendMsgChatroom(kind:integer;from,nick,tstr:string);
                       function Chatroom:boolean;
                       procedure ReadMail;
                       procedure Provchatadd(src:string);
                       procedure WriteMail;
                       procedure CompareMail;
                       procedure Cmdinput(var tmp1,tmp2,tmp3:string;a:boolean);
                       procedure AdminList;
                       procedure User;
                       function go(there:string):boolean;
                       procedure WriteMemo(toid,text:string);
                       procedure Chatting;
                       procedure SendTime;
                       procedure Board(kind:integer);
                       procedure MotherMenu;
                       procedure SendMsg(SrcString: string);
                       procedure MessageTo(who,text:string);
                       procedure Msgr;
                       procedure Msgb;
                       procedure EditMyData;
                       function Input:string;
                       function ReadMsg:string;
                       function commonfunc(str1,str2,str3:string;canmove:boolean):integer;
                       procedure Guest;
                       function writetoboard(title:string;var tmpnum:integer;lines:integer):tthreadmethod;
                private
                public
                      property SendStr:string write SendMsg;
                      property RecvStr:string Read ReadMsg;
         end;

var userlist:array[1..MaxUser] of TUser;

procedure closeall;
procedure executeuser(socketid:integer);
procedure adduser(socketid:integer;ipaddr:integer);
procedure Deleteuser(socketid:integer);
function userconnected(id:string):boolean;

implementation
uses utils, sysutils,socket,winsock,mainunit,windows,log;

destructor TUser.Destroy;
var i:integer;
begin
//     mainform.ListBox1.Items.delete(mainform.ListBox1.Items.IndexOfObject(Self));
     mainform.listview1.items.delete(mainform.listview1.Items.indexof(listitem));
     userlist[ulid]:=nil;
     logwrite( '접속이 종료되었습니다. ID('+ID+'), 소켓 '+inttostr(SockID));
     try
      if mypos.kind=2 then begin
       if roomnum>0 then begin
        if mypos.chat.rooms[roomnum]<>nil then begin
          for i:=1 to 12 do begin
            if mypos.chat.rooms[roomnum].users[i]<>nil then begin
               if mypos.chat.rooms[roomnum].users[i]=self then begin
                  mypos.chat.rooms[roomnum].users[i]:=nil;
                  dec(mypos.chat.rooms[roomnum].nowuser);
                  continue;
               end;
               tuser(mypos.chat.rooms[roomnum].users[i]).sendstr:=esc+'7'+esc+'[21;2H'+' *** '+id+'('+myname+') 님께서 짤렸습니다. ***'+crlf+esc+'8';
               if mypos.chat.rooms[roomnum].master=self then
                  mypos.chat.rooms[roomnum].master:=mypos.chat.rooms[roomnum].users[i];
            end;
          end;
          if mypos.chat.Rooms[roomnum].nowuser=0 then begin
            mypos.chat.Rooms[roomnum].free;
            mypos.chat.Rooms[roomnum]:=nil;
          end;
       end;
      end else
       mypos.chat.waiting[-roomnum]:=nil;
     end;
     except
     end;
     if id='guest' then begin
        try
         deletefile(pchar(exedir+'userdata\'+tmpid+'.id'));
        except
        end;
     end;
     FrmConnection.TotalUser:=FrmConnection.TotalUser-1;
     closesocket(sockid);
//     free;
     inherited;
end;

procedure TUser.CmdInput(var tmp1,tmp2,tmp3:string;a:boolean);
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

constructor TUser.init(SocketID:integer; IPAddr:integer; ctype:TTerminalType);
var i:integer;
begin
     inherited;
     Sendbeep:=true;
     for i:=1 to 12 do
         provmsg[i]:='';
     sockid:=socketid;
     logwrite(iptostr(ipaddr)+', ' +inttostr(sockid)+'번 소켓 접속');
     lastinputtime:=timegettime;
     Clienttype:=ctype;
     MyIP:=ipaddr;
     mypos:=TopNode;
     index:=topnode.index;
     state:=0;
end;

procedure TUser.Execute;
var
    pass:string;
    file1:textfile;
    tmppass:string;
    tmpi:integer;
    mails:integer;
    tmpstr:tstringlist;
    tmp:string;
begin
  self.priority:=tpNormal;

  SendStr:=iac+will+chr(3)+iac+will+echo;
  SendStr:=crlf+' EasyBBS builder BUILD '+inttostr(buildnum)
  +', 플랫폼 '+WindowsVersion+crlf+' 개발자 E-Mail : innoboy@nownuri.net. '+crlf+' 이 버젼의 최대 동시접속자 수는 '+inttostr(MaxUser)+'명으로 제한되어 있습니다.'+crlf+crlf+crlf;
  SendStr:=loginmessage+crlf+crlf;
  if MainForm.n5.checked then begin
     sendstr:=' 접속이 허용되지 않습니다.'+crlf+crlf;
     sendstr:=crlf;
     destroy;
     exit;
  end;

  SendStr:=IAC+WONT+ECHO+Crlf+' ID가 없으신 분은 ID란에 손님 또는 GUEST라고 기입해 주십시오.'+CRLF;
  repeat
    SendMsg(crlf+' ID       : '+iac+will+echo);
    ID:=lowercase(Input);
    if terminated then exit;
    if (ID='손님') or (ID='guest') then begin
       listitem.Caption:='가입중';
       listitem.SubItems[0]:='가입중';
       Guest;
       try
         free;
       except
       end;
       exit;
    end;
    echo_star:=true;
    SendMsg(' PASSWORD : ');
    pass:=Input;
    echo_star:=false;
  //  if fileexists(exedir+'\userdata\'+id+'.pwd') then begin
    try
       assignfile(file1,exedir+'\userdata\'+id+'.dat');
       reset(file1);
       readln(file1,tmppass);
       closefile(file1);
       if tmppass<>pass then begin
          sendstr:='잘못된 비밀번호입니다.'
       end else begin
           password:=tmppass;
           if not MultiLogin then begin
                for tmpi:=1 to MaxUser do begin
                        try
                                if (Userlist[tmpi]<>Self) and (userlist[tmpi]<>nil) then
                                        if (UserList[tmpi].id=id) and (UserList[tmpi].MyName<>'') then begin
                                                Sendstr:=CRLF+' 이 아이디가 이미 접속되어 있습니다. 종료시킬까요? (y/N) ';
                                        if Uppercase(Input)='Y' then begin
                                                userlist[tmpi].free;
                                        end else begin
                                                free;
                                                exit;
                                        end;
                                end;
                        except
                        end;
                end;
           end;

           assignfile(file1,exedir+'\userdata\'+id+'.dat');
           reset(file1);
           readln(file1);
           readln(file1,myname);
           closefile(file1);
           break;
       end;
    except
       sendstr:=crlf+'  그런 아이디는 존재하지 않습니다.';
    end;
  until terminated;

  while fileexists(exedir+'userdata\'+id+'.wat') do begin
        sendstr:='아직 가입처리중입니다. 다음에 다시 이용해주십시오.'+crlf;
        free;
  end;

  //  mainform.ListBox1.Items[(mainform.ListBox1.Items.IndexOfObject(Self))]:=ID+'('+MyName+') , IP : '+iptostr(myip);
  listitem.Caption:=ID;
  listitem.SubItems[0]:=MYNAME;

  logwrite( '사용자 접속. ID('+ID+'), 소켓 '+inttostr(SockID)+', IP:'+(iptostr(myip)));
  tmpi:=1;
  mails:=0;
  while fileexists(exedir+'mail\'+id+'.'+inttostr(tmpi)) do begin
     try
        assignfile(file1,exedir+'mail\'+id+'.'+inttostr(tmpi));
        reset(file1);
        readln(file1,tmp);
        if tmp<>'*' then begin
           readln(file1,tmp);readln(file1,tmp);readln(file1,tmp);readln(file1,tmp);readln(file1,tmp);readln(file1,tmp);
           if tmp='0' then
              inc(mails);
        end;
        closefile(file1);
     except
        try
          closefile(file1);
        except
        end;
     end;
     inc(tmpi);
  end;
  if mails>0 then begin
     sendstr:=crlf+crlf+crlf+'도착한 편지가 '+ic+inttostr(mails)+'통'+uic+' 있습니다.'+crlf;
  end else begin
     sendstr:=crlf+crlf+crlf+'도착한 편지가 없습니다.'+crlf;
  end;
  sendstr:='[Enter]를 누르십시오.';
  input;
  tmpstr:=tstringlist.create;
  try
    if fileexists(exedir+'mail\'+id+'.mem') then begin
        tmpstr.loadfromfile(exedir+'mail\'+id+'.mem');
        sendstr:=crlf+tmpstr.Text;
        deletefile(pchar(exedir+'mail\'+id+'.mem'));
        sendstr:=crlf+'[Enter]를 누르십시오.';
        input;
    end;
  except
  end;
  tmpstr.destroy;

  try
     if fileexists(Mypos.Dir+'\premenu.txt') then begin
        tmpstr:=tstringlist.create;
        tmpstr.LoadFromFile(mypos.dir+'\premenu.txt');
        sendstr:=ClearScr+tmpstr.text;
        sendstr:=Esc+'[20;4H[Enter]를 누르십시오.';
        input;
        tmpstr.free;
     end;
  except
  end;

  repeat
       case MyPos.kind of
            K_MotherMenu:
                mothermenu;
            K_Board:
                  board(0);
            K_Notice:
                  board(1);
            K_Hidden:
                  board(2);
            K_Rmail:
                  readmail;
            K_Wmail:
                writemail;
//            K_Cmail:
//                  comparemail;
            K_Chat:
                 chatting;
            k_EditMyData:
                 EditMyData;
            else
                input;
       end;
  until terminated;
end;

procedure TUser.AdminList;
var find:PAdminList;
    pos:TMyTreeNode;
begin
     find:=mypos.adminlist.next;
     pos:=mypos;
     sendstr:=crlf+'이 메뉴에서 권한을 가진 사람들'+crlf;
//     while (find<>nil) and (pos<>nil) do begin
     repeat
         if find=nil then begin
              if pos.parent<>nil then begin
                 pos:=pos.parent;
                 find:=pos.adminlist.next;
              end else begin
                  sendstr:=crlf;
                 exit;
              end;
         end else begin
           sendstr:='  '+find^.id+crlf;
           find:=find^.next;
         end;
     until false;
end;


procedure TUser.SendTime;
begin
     sendstr:=crlf+' 현재날짜 : '+datetostr(date)+crlf;
     sendstr:=' 현재시각 : '+timetostr(time)+crlf+crlf;
end;

procedure TUser.Profile(id:string);
var userdata:tstringlist;
begin
   userdata:=tstringlist.create;
 try
   id:=lowercase(id);
   userdata.LoadFromFile(exedir+'userdata\'+id+'.dat');
   SendStr:=crlf+'   아 이 디 : '+id+' , 이름 : '+userdata[1]+' , 현재 ';
   if userconnected(id) then
      sendstr:=ic+'[접속중]'+uic+crlf
   else
       sendstr:='[비접속]'+crlf;


   SendStr:='   소    속 : '+userdata[3]+crlf;
   SendStr:='   자기소개 1- '+userdata[9]+crlf;
   SendStr:='            2- '+userdata[10]+crlf;
   SendStr:='            3- '+userdata[11]+crlf+crlf;
 except
       sendstr:='  잘못된 ID입니다. '+crlf;
 end;
   userdata.Free;
end;

procedure TUser.Provchatadd(src:string);
var i:integer;
begin
                 for i:=1 to 19 do begin
                  provchat[i]:=provchat[i+1];
                end;
               provchat[20]:=src;
end;

procedure TUser.SendMsgChatroom(kind:integer;from,nick,tstr:string);
begin

   try
     case kind of
          1:begin
                 sendstr:=esc+'7'+esc+'[21;2H'+' *** '+from+'('+nick+') 님께서 입장하셨습니다. ***'+crlf+esc+'8';
                 provchatadd(esc+'7'+esc+'[21;2H'+' *** '+from+'('+nick+') 님께서 입장하셨습니다. ***'+crlf+esc+'8');
          end;
          2:begin
                 sendstr:=esc+'7'+esc+'[21;2H'+' *** '+from+'('+nick+') 님께서 퇴장하셨습니다. ***'+crlf+esc+'8';
                 provchatadd(esc+'7'+esc+'[21;2H'+' *** '+from+'('+nick+') 님께서 퇴장하셨습니다. ***'+crlf+esc+'8');
          end;
          3:begin
                 sendstr:=esc+'7'+esc+'[21;2H'+' *** 방장이 인원수를 조정하였습니다. ***'+crlf+esc+'8';
          end;
          4:begin
                 SendStr:=ESC+'7'+esc+'[2;2H'+esc+'[=2K'+MyPos.Index+midprt(mypos.chat.rooms[roomnum].title);
                 sendstr:=esc+'[21;2H'+' *** 방장이 방제를 바꾸었습니다. ***'+crlf+esc+'8';
          end;
          5:begin
//                 while length(tstr)>0 do begin
                    sendstr:=esc+'7'+ic+esc+'[21;2H'+format('%-13s(%-9s %s'+crlf+esc+'8',[from+uic,nick+')',copy(tstr,1,80)]);
//                    tstr:=copy(tstr,60,length(tstr)-59);
//                 end;
                 provchatadd(esc+'7'+ic+esc+'[21;2H'+format('%-13s(%-9s %s'+crlf+esc+'8',[from+uic,nick+')',copy(tstr,1,80)]));
          end;
          6:begin
//                 while length(tstr)>0 do begin
                              sendstr:=esc+'7'+esc+'[21;2H'+format('%-13s(%-9s %s'+crlf+esc+'8',[from+uic,nick+')',copy(tstr,1,80)]);
                              provchatadd(esc+'7'+esc+'[21;2H'+format('%-13s(%-9s %s'+crlf+esc+'8',[from+uic,nick+')',copy(tstr,1,80)]));
//                              tstr:=copy(tstr,60,length(tstr)-59);
//                 end;
          end;
          7:begin
                 sendstr:=esc+'7'+esc+'[21;2H'+' * '+nick+tstr+crlf+esc+'8';
                 provchatadd(esc+'7'+esc+'[21;2H'+' * '+nick+tstr+crlf+esc+'8');
          end;
     end;
   except
   end;
//
end;

procedure TUser.EditMyData;
var mydata:tstringlist;
    tmpstr:string;
    tmp1,tmp2:string;
    file1:textfile;
begin
   mydata:=tstringlist.create;
 try
   mydata.LoadFromFile(exedir+'userdata\'+id+'.dat');
   repeat
         Sendstr:=ClearScr+TopMessage+' '+Mypos.Index+MidPrt(MyPos.Name)+LineMessage;
         SendStr:='   아 이 디 : '+id+crlf;
//         SendStr:='   주민번호 : '+mydata[1]+crlf;
         SendStr:='1. 비밀번호 : '+copy('*************',1,length(password))+crlf;
         SendStr:='2. 주    소 : '+mydata[4]+crlf;
         SendStr:='3. 소    속 : '+mydata[3]+crlf;
         SendStr:='4. 전화번호 : '+mydata[5]+crlf;
         SendStr:='5. 삐삐번호 : '+mydata[6]+crlf;
         SendStr:='6. 휴대전화 : '+mydata[7]+crlf;
         SendStr:='   가입번호 : '+mydata[8]+crlf;
         SendStr:='7. 자기소개 : '+mydata[9]+crlf;
         SendStr:='              '+mydata[10]+crlf;
         SendStr:='              '+mydata[11]+crlf+crlf;
         if terminated then exit;
         repeat
               sendstr:='바꿀 번호(더이상 없으면 enter) : ';
               tmpstr:=input;
               try
                  if tmpstr='' then begin
                     break;
                  end;
                  case strtoint(tmpstr) of
                   1:begin
                       echo_star:=true;
                       repeat
                         sendstr:=' * 비밀번호는 입력즉시 적용됩니다.'+crlf;
                         sendstr:=' 비밀번호 : ';
                         tmp1:=input;
                         if length(tmp1)<4 then begin
                            sendstr:='비밀번호는 4자 이상이어야 합니다.'+crlf;
                            echo_star:=false;
                            raise exception.create(' 비밀번호는4자이상. ');
                            continue;
                         end;
                         break;
                       until false;
                       repeat
                         sendstr:=' 확    인 : ';
                         tmp2:=input;
                         if tmp1<>tmp2 then begin
                            sendstr:=' 두 번호가 틀립니다.'+crlf;
                            echo_star:=false;
                            raise exception.create(' 비밀번호확인틀림. ');
                            continue;
                         end else begin
                             password:=tmp1;
                             echo_star:=false;
                             break;
                         end;
                         break;
                       until false;
                       break;
                   end;
                   2:begin
                          sendstr:='주소 : ';
                          mydata[4]:=input;
                          break;
                   end;
                   3:begin
                          sendstr:='소속 : ';
                          mydata[3]:=input;
                          break;
                   end;
                   4:begin
                          sendstr:='전화번호 : ';
                          mydata[5]:=input;
                          break;
                   end;
                   5:begin
                          sendstr:='삐삐번호 : ';
                          mydata[6]:=input;
                          break;
                   end;
                   6:begin
                          sendstr:='휴대전화 : ';
                          mydata[7]:=input;
                          break;
                   end;
                   7:begin
                          sendstr:='1 - ';
                          mydata[9]:=input;
                          sendstr:='2 - ';
                          mydata[10]:=input;
                          sendstr:='3 - ';
                          mydata[11]:=input;
                          break;
                   end;
                  end;
               except
               end;
         until terminated;
         if tmpstr='' then begin
            break;
         end;
   until false;
   sendstr:='적용하시겠습니까?(Y/n)';
   if uppercase(input)<>'N' then begin
      mydata.SaveToFile(EXEDIR+'\USERDATA\'+ID+'.DAT');
   end;
 except
   sendstr:=' 오류입니다.';
 end;
   mydata.free;
   mypos:=mypos.parent;
end;

function TUser.Chatroom:boolean;
var tstr:array[1..3] of string;
    i,j:integer;
    s,tmproom,foundroom,nowviewroom:integer;
    provpos:tmytreenode;
    tmpemo,tmpemo2:string;
begin
  provpos:=mypos;
  chatroom:=false;
  try
     nowviewroom:=1;
     chatroom:=false;

     SendStr:=crlf+crlf+inttostr(roomnum)+'번 대화실에 들어갑니다'+crlf+ClearScr;
     Sendstr:=esc+'[04;21r';
     SendStr:=TopMessage+' '+Mypos.Index+midprt(mypos.chat.rooms[roomnum].title)+LineMessage;
     SendStr:=esc+'[22;1H'+linemessage;
     inc(mypos.chat.Rooms[roomnum].nowuser);
     for i:=1 to 12 do
         if mypos.chat.rooms[roomnum].users[i]<>nil then begin
           try
            tuser(mypos.chat.rooms[roomnum].users[i]).sendmsgchatroom(1,id,chatname,'');
           except
           end;
         end;

     repeat
           Sendstr:=esc+'[23;1H'+esc+'[=2K'+' 입력 : ';
           cmdinput(tstr[1],tstr[2],tstr[3],true);
           Sendstr:=esc+'[23;1H'+esc+'[=2K';
           if length(tstr[1])>0 then begin
              if tstr[1][1]='/' then begin
                 sendstr:=esc+'[21;1H';
                 tstr[1]:=lowercase(tstr[1]);
                 commonfunc(copy(tstr[1],2,10),tstr[2],tstr[3],false);

                 if (tstr[1]='/z') then begin
                    SendStr:=ClearScr+TopMessage+' '+Mypos.Index+midprt(mypos.chat.rooms[roomnum].title)+LineMessage;
                    Sendstr:=esc+'[22;1H'+linemessage+esc+'[4;21r';
                    sendstr:=esc+'[21;1H';
                    for i:=1 to 20 do
                        sendstr:=provchat[i];
                 end;

                 if (tstr[1]='/st') then begin
                    if (lowercase(tstr[2])='wait') then begin
                       SendStr:=' << 대기실 >> '+crlf+crlf;
                       s:=0;
                       for i:=1 to MaxUser do
                           if mypos.chat.waiting[i]<>nil then begin
                             try
                              sendstr:=format('   %-8s(%-8s)' ,[tuser(mypos.chat.waiting[i]).id,tuser(mypos.chat.waiting[i]).chatname]);
                              inc(s);
                              if s mod 4=0 then sendstr:=crlf;
                             except
                             end;
                           end;
                       if s mod 5<>0 then sendstr:=crlf;
                    end;
                    if (lowercase(tstr[2])='al') or (lowercase(tstr[2])='n')then begin
                       SendStr:=crlf+' << 대화실 >> '+crlf+crlf;
                       if (nowviewroom>999) or (lowercase(tstr[2])='al') then nowviewroom:=1;
                       foundroom:=0;
                       repeat
                             if assigned(mypos.chat.rooms[nowviewroom]) then begin
                                case mypos.chat.rooms[nowviewroom].kind of
                                     1: begin
                                        s:=0;
                                        sendstr:=format('[%3d] 공개  (%3d/%3d) %s',[nowviewroom,mypos.chat.rooms[nowviewroom].nowuser,mypos.chat.rooms[nowviewroom].totaluser,mypos.chat.rooms[nowviewroom].title+crlf]);
                                        for i:=1 to 12 do begin
                                          try
                                            if mypos.chat.rooms[nowviewroom].users[i]<>nil then begin
                                               sendstr:=format('  %-8s(%-8s)',[tuseR(mypos.chat.rooms[nowviewroom].users[i]).id,tuseR(mypos.chat.rooms[nowviewroom].users[i]).chatname]);
                                               inc(s);
                                               if s mod 4=0 then sendstr:=crlf;
                                            end;
                                          except
                                          end;
                                        end;
                                        sendstr:=crlf;
                                        inc(foundroom);
                                     end;
                                     2: begin
                                        sendstr:=format('[%3d] 비공개(%3d/%3d) %s',[nowviewroom,mypos.chat.rooms[nowviewroom].nowuser,mypos.chat.rooms[nowviewroom].totaluser,mypos.chat.rooms[nowviewroom].title+crlf]);
                                        s:=0;
                                        for i:=1 to 12 do begin
                                          try
                                            if mypos.chat.rooms[nowviewroom].users[i]<>nil then begin
                                               sendstr:=format('  %-8s(%-8s)',[tuseR(mypos.chat.rooms[nowviewroom].users[i]).id,tuseR(mypos.chat.rooms[nowviewroom].users[i]).chatname]);
                                               inc(s);
                                               if s mod 4=0 then sendstr:=crlf;
                                            end;
                                          except
                                          end;
                                        end;
                                        inc(foundroom);
                                     end;
                                end;
                             end;
                             inc(nowviewroom);
                       until (nowviewroom>999) or (foundroom=5);
                       sendstr:=crlf+' ** 처음부터 보기(st al), 다음 화면 보기(st n) **'+crlf+crlf;
                    end;
                    try
                      if tstr[2]<>'' then
                       tmproom:=strtoint(tstr[2])
                      else
                          tmproom:=roomnum;
                      if not assigned(mypos.chat.rooms[tmproom]) then raise exception.create('없는 대화방');
                      case mypos.chat.rooms[tmproom].kind of
                        1: begin
                           sendstr:=format('[%3d] 공개  (%3d/%3d) %s',[tmproom,mypos.chat.rooms[tmproom].nowuser,mypos.chat.rooms[tmproom].totaluser,mypos.chat.rooms[tmproom].title+crlf]);
                           sendstr:='  방장 : '+tuser(mypos.chat.rooms[tmproom].master).id+crlf;
                        end;
                        2: begin
                             sendstr:=format('[%3d] 비공개(%3d/%3d) %s',[tmproom,mypos.chat.rooms[tmproom].nowuser,mypos.chat.rooms[tmproom].totaluser,mypos.chat.rooms[tmproom].title+crlf]);
                        end;
                        3: begin
                           if roomnum=tmproom then sendstr:=format('[%3d] 숨은방(%3d/%3d) %s',[tmproom,mypos.chat.rooms[tmproom].nowuser,mypos.chat.rooms[tmproom].totaluser,mypos.chat.rooms[tmproom].title+crlf]);
                        end;
                      end;
                      if (roomnum=tmproom) or (mypos.chat.rooms[tmproom].kind<3) then begin
                       s:=0;
                       for i:=1 to 12 do
                           if mypos.chat.rooms[tmproom].users[i]<>nil then begin
                               sendstr:=format('  %-8s(%-8s)',[tuseR(mypos.chat.rooms[tmproom].users[i]).id,tuseR(mypos.chat.rooms[tmproom].users[i]).chatname]);
                               inc(s);
                               if s mod 4=0 then sendstr:=crlf;
                            end;
                           sendstr:=crlf;
                      end;
                    except
                    end;
                 end;

             if (tstr[1]='/c') OR (tstr[1]='/h') then begin
                sendstr:=' 대화명변경 AL [대화명] 예) al 다소니'+crlf;
                sendstr:=' 방제변경 E TITLE [방제] 인원변경 E USER [인원]'+crlf;
                sendstr:=' 방 내용  ST    대화실보기 ST AL   화면지우기 CLS   지난화면 Z'+crlf;
                sendstr:=' 대기실보기 ST WAIT'+CRLF+CRLF;

             end;

                 if tstr[1]='/t' then begin
                    sendstr:=esc+'[1;30r';
                    dec(mypos.chat.rooms[roomnum].nowuser);
                    chatroom:=true;
                    for i:=1 to 12 do begin
                        if mypos.chat.rooms[roomnum].users[i]<>nil then begin
                          try
                           if mypos.chat.rooms[roomnum].users[i]=self then begin
                              mypos.chat.rooms[roomnum].users[i]:=nil;
                              continue;
                           end;
                           try
                             tuser(mypos.chat.rooms[roomnum].users[i]).sendmsgchatroom(2,id,chatname,'');
                             if mypos.chat.rooms[roomnum].master=self then
                                mypos.chat.rooms[roomnum].master:=mypos.chat.rooms[roomnum].users[i]
                           except
                           end;
                          except
                          end;
                        end;
                    end;
                    mypos:=topnode;
                    exit;
                 end;
                 if tstr[1]='/cls' then begin
                    SendStr:=ClearScr+TopMessage+' '+Mypos.Index+midprt(mypos.chat.rooms[roomnum].title)+LineMessage;
                    Sendstr:=esc+'[22;1H'+linemessage+esc+'[4;21r';
                 end;
                 if tstr[1]='/e' then begin
                   if mypos.chat.rooms[roomnum].master=self then begin
                    tstr[2]:=lowercase(tstr[2]);
                    if tstr[2]='user' then
                       try
                          if (strtoint(tstr[3])>2) and (strtoint(tstr[3])<=12) then begin
                             mypos.chat.rooms[roomnum].totaluser:=strtoint(tstr[3]);
                             for i:=1 to 12 do
                                 if mypos.chat.rooms[roomnum].users[i]<>nil then begin
                                    tuser(mypos.chat.rooms[roomnum].users[i]).sendmsgchatroom(3,'','','');
                                 end;
                          end;
                       except
                       end;
                    if tstr[2]='title' then begin
                             mypos.chat.rooms[roomnum].title:=copy(tstr[3],1,60);
                             for i:=1 to 12 do
                                 if mypos.chat.rooms[roomnum].users[i]<>nil then begin
                                    tuser(mypos.chat.rooms[roomnum].users[i]).SendMsgChatroom(4,'','','');
                                 end;
                    end;
                   end;
                 end;
                 if tstr[1]='/go' then begin
                    provpos:=mypos;
                    if go(tstr[2]) then begin
                       sendstr:=esc+'[1;30r';
                       dec(provpos.chat.rooms[roomnum].nowuser);
                       chatroom:=true;
                       for i:=1 to 12 do
                         if provpos.chat.rooms[roomnum].users[i]<>nil then begin
                           if provpos.chat.rooms[roomnum].users[i]=self then begin
                              provpos.chat.rooms[roomnum].users[i]:=nil;
                              continue;
                           end;
                           tuser(provpos.chat.rooms[roomnum].users[i]).sendmsgchatroom(2,id,chatname,'');
                           if provpos.chat.rooms[roomnum].master=self then
                              provpos.chat.rooms[roomnum].master:=provpos.chat.rooms[roomnum].users[i]
                         end;
                       exit;
                    end;
                 end;
                 if tstr[1]='/al' then begin
                    chatname:=tstr[2];
                    sendstr:='대화명이 변경되었습니다.'+crlf;
                 end;
                 if tstr[1]='/in' then begin
                    if mypos.chat.rooms[roomnum].kind>1 then begin
                        messageto(tstr[2],'대화방에서 초청 : '+mypos.index+'의 '+inttostr(roomnum)+'번 방, 비밀번호 : '+mypos.chat.rooms[roomnum].pass);
                    end else begin
                        messageto(tstr[2],'대화방에서 초청 : '+mypos.index+'의 '+inttostr(roomnum)+'번 방');
                    end;
                 end;

                 if (tstr[1]='/q') or (tstr[1]='/p') then begin
                    sendstr:=esc+'[1;30r';
                    dec(mypos.chat.rooms[roomnum].nowuser);
                    for i:=1 to 12 do
                        if mypos.chat.rooms[roomnum].users[i]<>nil then begin
                          try
                           if mypos.chat.rooms[roomnum].users[i]=self then begin
                              mypos.chat.rooms[roomnum].users[i]:=nil;
                              continue;
                           end else begin
                             try
                              tuser(mypos.chat.rooms[roomnum].users[i]).sendmsgchatroom(2,id,chatname,'');
                              if mypos.chat.rooms[roomnum].master=self then
                                mypos.chat.rooms[roomnum].master:=mypos.chat.rooms[roomnum].users[i]
                             except
                             end;
                           end;
                          except
                          end;
                        end;
                    exit;
                 end;

                 i:=1;
                 while (i<emotion.count) do begin
                       if '/'+emotion[i-1]=lowercase(tstr[1]) then begin
                          tmpemo:=emotion[i];
                          tmpemo2:='누군가';

                          for j:=1 to 12 do begin
                             if mypos.chat.rooms[roomnum].users[j]<>nil then begin
                                try
                                   if tuser(mypos.chat.rooms[roomnum].users[j]).id=tstr[2] then
                                      tmpemo2:=tuser(mypos.chat.rooms[roomnum].users[j]).chatname;
                                except
                                end;
                             end;
                          end;

                          if pos('%s',tmpemo)>0 then tmpemo:=copy(tmpemo,1,pos('%s',tmpemo)-1)+tmpemo2+copy(tmpemo,pos('%s',tmpemo)+2,length(tmpemo));
                          for j:=1 to 12 do begin
                            try
                              if mypos.chat.rooms[roomnum].users[j]<>nil then begin
                                tuser(mypos.chat.rooms[roomnum].users[j]).sendmsgchatroom(7,id,chatname,tmpemo);
                              end;
                            except
                            end;
                          end;
                       end;
                       inc(i,2);
                 end;
              end;
           end;
           try
             if length(tstr[1])>=0 then begin
                    if tstr[3]<>'' then
                        tstr[1]:=tstr[1]+' '+tstr[2]+' '+tstr[3]
                    else
                       if tstr[2]<>'' then
                         tstr[1]:=tstr[1]+' '+tstr[2];
               if tstr[1][1]<>'/' then begin
                 for i:=1 to 12 do begin
                  try
                    if mypos.chat.rooms[roomnum].users[i]<>nil then begin
                       if mypos.chat.rooms[roomnum].users[i]<>self then
                          tuser(mypos.chat.rooms[roomnum].users[i]).sendmsgchatroom(6,id,chatname,tstr[1])
                       else
                          sendmsgchatroom(5,id,chatname,tstr[1]);
                    end;
                  except
                  end;
               end;
              end;
             end;
           except
           end;
     until terminated;
  except
    for i:=1 to 12 do begin
        if provpos.chat.rooms[roomnum].users[i]<>nil then begin
           if provpos.chat.rooms[roomnum].users[i]=self then begin
                provpos.chat.rooms[roomnum].users[i]:=nil;
                continue;
           end;
           try
             tuser(provpos.chat.rooms[roomnum].users[i]).sendmsgchatroom(2,id,chatname,'');
             if provpos.chat.rooms[roomnum].master=self then
                 provpos.chat.rooms[roomnum].master:=provpos.chat.rooms[roomnum].users[i]
           except
           end;
        end;
    end;
    try
    except
    end;
    sendstr:='오류입니다.';
  end;
  sendstr:=esc+'[1;30r';
end;

procedure TUser.WriteMemo(toid,text:string);
var file1:textfile;
begin
  try
    if fileexists(exedir+'userdata\'+toid+'.id') and
       fileexists(exedir+'userdata\'+toid+'.dat') then begin
     assignfile(file1,exedir+'mail\'+toid+'.mem');
     if fileexists(exedir+'mail\'+toid+'.mem') then append(file1)
     else rewrite(file1);
     writeln(file1,' '+ID+'('+myname+') 님께서 '+datetostr(date)+','+timetostr(time)+'에 보내신 메세지');
     writeln(file1,' => '+text);
     closefile(file1);
     sendstr:=' 메모를 남겼습니다. '+crlf;
    end else begin
        sendstr:=' 없는 ID입니다. '+CRLF;
    end;
  except
  end;
end;

procedure TUser.ReadMail;
var nowview:integer;
    mailstr:TStringlist;
    foundview:integer;
    viewlines,nowlines,lines,i,nextview:integer;
    nums:tstringlist;
    tmpinput:array[1..3] of string;
    file1:textfile;
    tmp,tmp1,tmp2,tmp3,tmp4,tmp5,tmp6,tmp7:string; { -_-;;; huhjup }
begin
   Mailstr:=TStringlist.Create;
   Nums:=TStringlist.Create;
   try
     nowview:=1;
     while fileexists(exedir+'mail\'+id+'.'+inttostr(nowview)) do begin
      try
       assignfile(file1,exedir+'mail\'+id+'.'+inttostr(nowview));
       reset(file1);
       readln(file1,tmp);
       closefile(file1);
       if tmp<>'*' then begin
           nums.Insert(0,(inttostr(nowview)));
       end;
      except
       try
         closefile(file1);
       except
       end;
      end;
      inc(nowview);
     end;
     nowview:=0;
     nextview:=0;
     repeat
       Sendstr:=ClearScr+TopMessage+' '+Mypos.Index+MidPrt(MyPos.Name)+LineMessage;
       SendStr:='   번호 보낸ID   이  름   날 짜  쪽 제목'+crlf;
       SendStr:=dotline;
       foundview:=0;
       for i:=nowview to nums.count-1 do begin
           nextview:=i+1;
           try
              assignfile(file1,exedir+'mail\'+id+'.'+nums[i]);
              reset(file1);
              readln(file1,tmp);
              if tmp<>'*' then begin

                readln(file1,tmp1); readln(file1,tmp2); readln(file1,tmp3); readln(file1,tmp4); readln(file1,tmp5);
                readln(file1,tmp6); readln(file1,tmp7);
                 try
                   closefile(file1);
                 except
                 end;
                inc(foundview);
                if tmp6<>'0' then
                  SendStr:='R'
                else
                  SendStr:=' ';
                SendStr:=format('%6d %-8s %-8s %-5s %4s %s'+crlf,[i+1,tmp2,tmp3,copy(tmp4,length(tmp4)-4,5),tmp7,tmp1]);
                if foundview mod 15=0 then break;
              end;
                 try
                   closefile(file1);
                 except
                 end;
           except
                 try
                   closefile(file1);
                 except
                 end;
           end;
       end;
       sendstr:=linemessage;

       repeat
             Sendstr:=' 명령어안내(C) 초기화면(T) 이동(GO,P) 쪽지(TO) 종료(X,Bye)'+crlf+' 선택> ';
             cmdinput(tmpinput[1],tmpinput[2],tmpinput[3],false);
             if commonfunc(tmpinput[1],tmpinput[2],tmpinput[3],true)=1 then begin
                mailstr.free;
                nums.free;
                exit;
             end;
             if terminated then begin
                mailstr.free;
                nums.free;
                exit;
             end;
             if tmpinput[1]='c' then begin
                sendstr:=' 지우기 D [글번호]      예) d 1'+crlf+crlf;
             end;

             if tmpinput[1]='b' then begin
                nowview:=nowview-16;
                if nowview<0 then nowview:=0;
                break;
             end;

             if tmpinput[1]='' then begin
                if nextview>=nums.count then begin
                   sendstr:='더이상 없습니다.'+crlf;
                end else begin
                    nowview:=nextview;
                    break;
                end;
             end;

             if tmpinput[1]='d' then begin
               try
                 mailstr.loadfromfile(exedir+'mail\'+id+'.'+inttostr(strtoint(nums[strtoint(tmpinput[2])-1])));
                 mailstr[0]:='*';
                 mailstr.savetofile(exedir+'mail\'+id+'.'+inttostr(strtoint(nums[strtoint(tmpinput[2])-1])));
                 sendstr:=' 삭제했습니다.'+crlf;
               except
               end;
             end;

             try
                if (strtoint(tmpinput[1])>0) and (strtoint(tmpinput[1])<=nums.count) then begin
                  lines:=strtoint(nums[strtoint(tmpinput[1])-1]);
                  repeat
                   mailstr.LoadFromFile(exedir+'mail\'+id+'.'+inttostR(lines));
                   mailstr.strings[6]:=inttostr(strtoint(mailstr.strings[6])+1);
                   mailstr.SaveToFile(exedir+'mail\'+id+'.'+inttostR(lines));
                   ViewLines:=1;
                   NowLines:=1;
                   repeat
                      Sendstr:=ClearScr+TopMessage+' '+Mypos.Index+MidPrt(MyPos.Name)+LineMessage;
                      SendStr:=' 제 목  : '+mailstr[1]+crlf;
                      SendStr:=format(' 보낸이 : %-8s(%-8s)   %s %s '+crlf,[mailstr[2],mailstr[3],mailstr[4],mailstr[5]]);
                      SendStr:=dotline;
                      repeat
                           if viewlines+7<mailstr.count then
                               SendStr:=mailstr[7 +viewlines]+crlf
                           else
                               Break;
                            if viewlines-nowlines>12 then break;
                          inc(viewlines);
                      until terminated;
                      SendStr:=linemessage;
                      repeat
                            Sendstr:=' 명령어안내(C) 초기화면(T) 이동(GO,P,B) 쪽지(TO) 종료(X,Bye)'+crlf+' 선택> ';
                            cmdinput(tmpinput[1],tmpinput[2],tmpinput[3],false);
                            if tmpinput[1]='z' then begin
                               viewlines:=NowLines;
                               break;
                            end;

                            if tmpinput[1]='go' then begin
                               if go(tmpinput[2]) then begin
                                  mailstr.free;
                                  nums.free;
                                  exit;
                               end;
                            end;

                            if tmpinput[1]='t' then begin
                                mypos:=topnode;
                                mailstr.free;
                                nums.free;
                                exit;
                            end;

                            if tmpinput[1]='b' then begin
                               nowlines:=nowlines-14;
                               if nowlines<1 then nowlines:=1;
                               viewlines:=nowlines;
                               break;
                            end;

                            if tmpinput[1]='p' then begin
                               break;
                            end;

                            if tmpinput[1]='' then begin
                               if viewlines+7>=mailstr.count then begin
                                  sendstr:=' 더이상 없습니다.'+crlf+crlf;
                                  continue;
                               end else begin
                                   nowlines:=nowlines+14;
                                   viewlines:=nowlines;
                                   break;
                               end;
                            end;
                            try
                             if strtoint(tmpinput[1])=strtoint(inttostr(strtoint(tmpinput[1]))) then begin
                               nowlines:=(strtoint(tmpinput[1])-1)*14+1;
                               if nowlines<1 then nowlines:=1;
                               if nowlines+7>mailstr.Count then begin
                                  sendstr:=' 그런 페이지는 없습니다.'+crlf+crlf;
                                  nowlines:=viewlines-13;
                                  if nowlines<1 then nowlines:=1;
                               end else begin
                                   viewlines:=nowlines;
                                   break;
                               end;
                             end;
                            except
                            end;

                            if commonfunc(tmpinput[1],tmpinput[2],tmpinput[3],true)=1 then exit;
                            if tmpinput[1]='c' then begin
                               sendstr:=' 이전페이지 B'+crlf+crlf;
                            end;

                      until false;
                      if (tmpinput[1]='p') then
                               break;
                   until false;
                   if (tmpinput[1]='p') then
                      break;
                  until false;
                  if (tmpinput[1]='p') then
                     break;
               end;
             except
             end;

       until terminated;
     until terminated;
  except
    mypos:=mypos.prov;
  end;
  mailstr.free;
  nums.free;
end;

procedure TUser.WriteMail;
var tmp,tmptext,title,toid:string;
    file1:textfile;
    lines,i:integer;
begin
   try
                SendStr:=ClearScr+TopMessage+' '+Mypos.Index+MidPrt(MyPos.Name)+LineMessage;
                repeat
                      SendStr:=' 보낼 ID : ';
                      toid:=Input;
                      if not fileexists(Exedir+'userdata\'+toid+'.dat') then begin
                         sendstr:= ' 그런 ID는 없습니다. 취소하시겠습니까? (Y/n) ';
                         if lowercase(input)<>'n' then begin
                            mypos:=mypos.parent;
                            exit;
                         end;
                         continue;
                      end;
                      break;
                until terminated;
                repeat
                      SendStr:=' 제목 : ';
                      title:=Input;
                      if length(title)<4 then begin
                         SendStr:='제목은 4자 이상이어야 합니다.'+crlf;
                         SendStr:='취소하시겠습니까? (Y/n) ';
                         if lowercase(input)='y' then begin
                            mypos:=mypos.parent;
                            exit;
                         end;
                      end;
                until length(title)>=4;
                SendStr:=' 내용을 입력해 주십시오. 끝내시려면 ''.''을 치십시오.'+crlf;
                SendStr:=dotline;
                tmptext:='';
                lines:=0;
                repeat
                      tmp:=input;
                      if tmp<>'.' then begin
                         tmptext:=tmptext+tmp+crlf;
                         inc(lines);
                      end;
                until tmp='.';

                SendStr:='보내시겠습니까? (Y/n) ';
                tmp:=lowercase(input);

                if tmp<>'n' then begin
                   i:=1;
                   while fileexists(exedir+'mail\'+toid+'.'+inttostr(i)) do
                         inc(i);
                   assign(file1,exedir+'mail\'+toid+'.'+inttostr(i));
                   rewrite(file1);
                   writeln(file1,' ');
                   writeln(file1,title);
                   writeln(file1,id);
                   writeln(file1,myname);
                   writeln(file1,datetostr(date));
                   writeln(file1,timetostr(time));
                   writeln(file1,0);
                   writeln(file1,inttostr((lines div 14)+1));
                   write(file1,tmptext);
                   closefile(file1);
                end;
                mypos:=mypos.parent;
   except
         sendstr:='오류입니다.'+crlf;
   end;
end;

procedure TUser.CompareMail;
begin
//
end;

procedure TUser.Chatting;
var i,j:integer;
    s:integer;
    roomkind:string;
    pass:string;
    limit:string;
    tmpinput:array[1..3] of string;
    roomtitle:string;
    nowviewroom:integer;
    foundroom:integer;
    provpos:tmytreenode;
begin
  chatname:=myname;
  for i:=1 to MaxUser do
      if mypos.chat.Waiting[i]=nil then begin
         mypos.chat.waiting[i]:=self;
         roomnum:=-i;
         break;
      end;
  SendStr:=ClearScr+TopMessage+' '+Mypos.Index+MidPrt(MyPos.Name)+LineMessage;
  SendStr:=' << 대기실 >> '+crlf+crlf;
  s:=0;
  for i:=1 to MaxUser do
      if mypos.chat.waiting[i]<>nil then begin
        try
         sendstr:=format('   %-8s(%-8s)' ,[tuser(mypos.chat.waiting[i]).id,tuser(mypos.chat.waiting[i]).chatname]);
         inc(s);
         if s mod 4=0 then sendstr:=crlf;
        except
        end;
      end;
  if s mod 5<>0 then sendstr:=crlf;
  sendstr:=crlf+' ** 대화방 목록을 보시려면 <ENTER> 를 누르세요 ** '+crlf+linemessage;
  nowviewroom:=1;
  repeat
             Sendstr:=' 이동(GO,P) 처음부터(Z) 방개설(O) 참여(번호) 쪽지(TO) 종료(X,Bye)'+crlf+' 선택> ';
             cmdinput(tmpinput[1],tmpinput[2],tmpinput[3],false);
             if terminated then exit;
             commonfunc(tmpinput[1],tmpinput[2],tmpinput[3],false);
             if tmpinput[1]='o' then begin
                repeat
                      sendstr:= ' 방 종류(1:공개(기본),2:비공개,3:숨은방,0:취소) : ';
                      roomkind:=input;
                      if terminated then exit;
                      if roomkind='' then roomkind:='1';
                until (roomkind>='0') and (roomkind<='3');
                if roomkind='0' then continue;
                if roomkind>'1' then begin
                   repeat
                      echo_star:=true;
                      sendstr:= ' 비밀번호 : ';
                      pass:=input;
                      if length(pass)<4 then begin
                         sendstr:=' 비밀번호는 4자 이상이어야 합니다.'+crlf;
                         continue;
                      end;
                      sendstr:= ' 재입력 : ';
                      if input<>pass then begin
                         sendstr:=' 비밀번호가 틀립니다. 다시 입력해 주십시오.'+crlf;
                         pass:='';
                      end;
                      echo_star:=false;
                      if terminated then exit;
                   until length(pass)>=4;
                end;
                repeat
                      sendstr:=' 제한인원(3~12,ENTER:12명) : ';
                      limit:=input;
                      if limit='' then
                         limit:='12';
                      try
                         if (strtoint(limit)>=3) and (strtoint(limit)<=12) then
                            break;
                      except
                      end;
                until terminated;
                sendstr:= ' 제목 : ';
                roomtitle:=input;
                for i:=1 to 999 do
                    if mypos.chat.rooms[i]=nil then begin
                       mypos.chat.rooms[i]:=tchat.Create;
                       mypos.chat.rooms[i].pass:=pass;
                       mypos.chat.rooms[i].title:=roomtitle;
                       mypos.chat.rooms[i].kind:=strtoint(roomkind);
                       mypos.chat.rooms[i].master:=self;
                       mypos.chat.rooms[i].totaluser:=strtoint(limit);
                       mypos.chat.rooms[i].users[1]:=self;
                       mypos.chat.rooms[i].nowuser:=0;
                       mypos.chat.waiting[-roomnum]:=nil;
                       roomnum:=i;
                       sendstr:=' '+inttostr(i)+'번 방이 개설되었습니다. ';//crlf[ENTER]를 누르십시오.';
                       provpos:=mypos;
//                       input;
                       if chatroom then begin
                          try
                            if provpos.chat.Rooms[roomnum].nowuser=0 then begin
                               provpos.chat.Rooms[roomnum].free;
                               provpos.chat.rooms[roomnum]:=nil;
                            end;
                          except
                          end;
                          exit;
                       end;
                       if mypos.chat.Rooms[roomnum].nowuser=0 then begin
                          mypos.chat.Rooms[roomnum].free;
                          mypos.chat.rooms[roomnum]:=nil;
                       end;
                       for j:=1 to MaxUser do
                           if mypos.chat.Waiting[j]=nil then begin
                              mypos.chat.waiting[j]:=self;
                              roomnum:=-j;
                              break;
                           end;
                       SendStr:=ClearScr+TopMessage+' '+Mypos.Index+MidPrt(MyPos.Name)+LineMessage;
                       SendStr:=' << 대기실 >> '+crlf+crlf;
                       s:=0;
                       for j:=1 to MaxUser do
                           if mypos.chat.waiting[j]<>nil then begin
                              sendstr:=format('   %-8s(%-8s)' ,[tuser(mypos.chat.waiting[j]).id,tuser(mypos.chat.waiting[j]).chatname]);
                              inc(s);
                              if s mod 4=0 then sendstr:=crlf;
                           end;
                       if s mod 5<>0 then sendstr:=crlf;
                       sendstr:=crlf+' ** 대화방 목록을 보시려면 <ENTER> 를 누르세요 ** '+crlf+linemessage;
                       nowviewroom:=1;
                       break;
                    end;
             end;
             if tmpinput[1]='al' then begin
                chatname:=tmpinput[2];
                sendstr:='대화명이 변경되었습니다.'+crlf;
             end;
             if tmpinput[1]='z' then begin
                nowviewroom:=1;
                SendStr:=ClearScr+TopMessage+' '+Mypos.Index+MidPrt(MyPos.Name)+LineMessage;
                SendStr:=' << 대기실 >> '+crlf+crlf;
                s:=0;
                for i:=1 to MaxUser do
                    if mypos.chat.waiting[i]<>nil then begin
                      try
                       sendstr:=format('   %-8s(%-8s)' ,[tuser(mypos.chat.waiting[i]).id,tuser(mypos.chat.waiting[i]).chatname]);
                       inc(s);
                       if s mod 4=0 then sendstr:=crlf;
                      except
                      end;
                    end;
                if s mod 5<>0 then sendstr:=crlf;
                sendstr:=crlf+' ** 대화방 목록을 보시려면 <ENTER> 를 누르세요 ** '+crlf+linemessage;
             end;
             if tmpinput[1]='' then begin
              if nowviewroom>999 then
                 sendstr:=' 더 이상 없습니다.'+crlf
              else begin
                SendStr:=ClearScr+TopMessage+' '+Mypos.Index+MidPrt(MyPos.Name)+LineMessage;
                SendStr:=' << 대화실 >> '+crlf+crlf;
                foundroom:=0;
                repeat
                    if assigned(mypos.chat.rooms[nowviewroom]) then begin
                       case mypos.chat.rooms[nowviewroom].kind of
                        1: begin
                             sendstr:=format('[%3d] 공개  (%3d/%3d) %s',[nowviewroom,mypos.chat.rooms[nowviewroom].nowuser,mypos.chat.rooms[nowviewroom].totaluser,mypos.chat.rooms[nowviewroom].title+crlf]);
                             for i:=1 to 12 do begin
                               try
                                 if mypos.chat.rooms[nowviewroom].users[i]<>nil then
                                    sendstr:=format('  %-8s(%-8s)',[tuseR(mypos.chat.rooms[nowviewroom].users[i]).id,tuseR(mypos.chat.rooms[nowviewroom].users[i]).chatname]);
                               except
                               end;
                             end;
                             sendstr:=crlf;
                             inc(foundroom);
                        end;
                        2: begin
                             sendstr:=format('[%3d] 비공개(%3d/%3d) %s',[nowviewroom,mypos.chat.rooms[nowviewroom].nowuser,mypos.chat.rooms[nowviewroom].totaluser,mypos.chat.rooms[nowviewroom].title]);
                             for i:=1 to 12 do begin
                               try
                                 if mypos.chat.rooms[nowviewroom].users[i]<>nil then
                                    sendstr:=format('  %-8s(%-8s)',[tuseR(mypos.chat.rooms[nowviewroom].users[i]).id,tuseR(mypos.chat.rooms[nowviewroom].users[i]).chatname]);
                               except
                               end;
                             end;
                             inc(foundroom);
                        end;
                       end;
                    end;
                    inc(nowviewroom);
                until (nowviewroom>999) or (foundroom=5);
                sendstr:=crlf+linemessage;
              end;
             end;

             if tmpinput[1]='t' then begin
                mypos.chat.waiting[-roomnum]:=nil;
                mypos:=topnode;
                exit;
             end;
             if tmpinput[1]='p' then begin
                mypos.chat.waiting[-roomnum]:=nil;
                if mypos.parent<>nil then mypos:=mypos.parent;
                exit;
             end;
             if tmpinput[1]='go' then begin
                provpos:=mypos;
                if go(tmpinput[2]) then begin
                   provpos.chat.waiting[-roomnum]:=nil;
                   exit;
                end;
             end;
             if tmpinput[1]='' then continue;
             try
                if inttostr(strtoint(tmpinput[1]))=tmpinput[1] then
                   if (strtoint(tmpinput[1])>=0) and (strtoint(tmpinput[1])<=999)then
                      if mypos.chat.rooms[strtoint(tmpinput[1])]<>nil then begin
                        if mypos.chat.rooms[strtoint(tmpinput[1])].kind>1 then begin
                           echo_star:=true;
                           sendstr := ' 비밀번호 : ';
                           if mypos.chat.rooms[strtoint(tmpinput[1])].pass<>input then begin
                              echo_star:=false;
                              raise exception.create('대화방비번.');
                           end;
                           echo_star:=false;
                        end;
                        if mypos.chat.rooms[strtoint(tmpinput[1])].nowuser<mypos.chat.rooms[strtoint(tmpinput[1])].totaluser then begin
                         for i:=1 to 12 do
                             if mypos.chat.rooms[strtoint(tmpinput[1])].users[i]=nil then begin
                                mypos.chat.Waiting[-roomnum]:=nil;
                                roomnum:=strtoint(tmpinput[1]);
                                mypos.chat.rooms[strtoint(tmpinput[1])].users[i]:=self;
                                provpos:=mypos;
                                if chatroom then begin
                                   if provpos.chat.Rooms[roomnum].nowuser=0 then begin
                                      provpos.chat.Rooms[roomnum].free;
                                      provpos.chat.rooms[roomnum]:=nil;
                                   end;
                                   exit;
                                end;
                                if provpos.chat.Rooms[roomnum].nowuser=0 then begin
                                   provpos.chat.Rooms[roomnum].free;
                                   provpos.chat.rooms[roomnum]:=nil;
                                end;
                                for j:=1 to MaxUser do
                                    if mypos.chat.Waiting[j]=nil then begin
                                       mypos.chat.waiting[j]:=self;
                                       roomnum:=-j;
                                       break;
                                    end;
                                SendStr:=ClearScr+TopMessage+' '+Mypos.Index+MidPrt(MyPos.Name)+LineMessage;
                                SendStr:=' << 대기실 >> '+crlf+crlf;
                                s:=0;
                                for j:=1 to MaxUser do
                                    if mypos.chat.waiting[j]<>nil then begin
                                       sendstr:=format('   %-8s(%-8s)' ,[tuser(mypos.chat.waiting[j]).id,tuser(mypos.chat.waiting[j]).chatname]);
                                       inc(s);
                                       if s mod 4=0 then sendstr:=crlf;
                                    end;
                                if s mod 5<>0 then sendstr:=crlf;
                                sendstr:=crlf+' ** 대화방 목록을 보시려면 <ENTER> 를 누르세요 ** '+crlf+linemessage;
                                nowviewroom:=1;
                                break;
                             end;
                        end else
                            sendstr:=' 방이 꽉 찼습니다.'+crlf;
                      end;
             except
             end;
  until terminated;
  if mypos.chat.waiting[roomnum]<>nil then
     if mypos.chat.waiting[roomnum]=self then
        mypos.chat.waiting[roomnum]:=nil;
  mypos:=mypos.parent;
end;

function TUser.go(there:string):boolean;
var tmpindex:pindex;
begin
     tmpindex:=headindex;
     there:=uppercase(there);
      repeat
           tmpindex:=tmpindex^.next;
           if tmpindex^.menu.index=there then begin
              mypos:=tmpindex^.menu;
              go:=true;
              exit;
           end;
     until tmpindex^.next=nil;
     go:=false;
end;

function TUser.writetoboard(title:String;var tmpnum:integer;lines:integer):tthreadmethod;
begin
     TmpNum:=MyPos.Board.IndexByID.Add(id);
     MyPos.Board.CanAccess.Add('*');
     MyPos.Board.Name.Add(myname);
     MyPos.Board.Date.Add(datetostr(Date));
     MyPos.Board.Count.Add('0');
     mypos.Board.pages.add(inttostr((lines div 14)+1));
     MyPos.Board.IndexByTitle.Add(title);
end;

procedure TUser.Board(kind:integer);
var View:integer;
    Found:integer;
    i,tmpview,Next:integer;
    tmpinput:array[1..3] of string;
    title,tmp:string;
    tmptext:string;
    lines,tmpnum:integer;
    tmpstr:tstringlist;
    file1:textfile;

    viewlines,nowlines:integer;


    Boardindex:TStringlist;
begin
     Boardindex:=TStringList.Create;
     for i:=0 to MyPos.Board.CanAccess.Count-1 do begin
         if MyPos.Board.CanAccess[i]<>'*' then
            boardIndex.Add(inttostr(i));
     end;

     View:=boardindex.Count-1;
     Next:=view;
     repeat
       Sendstr:=ClearScr+TopMessage+' '+Mypos.Index+MidPrt(MyPos.Name)+LineMessage;
       if (kind=0) or (kind=1) then
         SendStr:='   번호 올린ID   이  름   날 짜 읽음  쪽 제목'+crlf;
       if kind=2 then
         SendStr:='   번호 날 짜 읽음  쪽 제목'+crlf;

       SendStr:=dotline;
       Found:=0;
       while(next>=0) and (found<15) do begin
          tmpnum:=strtoint(boardindex[next]);
          inc(found);
          if (kind=0) or (kind=1) then begin
            with mypos.board do
               SendStr:=format('%7d %-8s %-8s %-5s %4s%4s %s'+crlf,[tmpnum+1,IndexByID.strings[tmpnum]
                                  ,Name[tmpnum],copy(Date.strings[tmpnum],length(Date.strings[tmpnum])-4,5),count.strings[tmpnum],pages.strings[tmpnum],copy(IndexByTitle.strings[tmpnum],1,39)]);
          end else begin
            with mypos.board do
               SendStr:=format('%7d %-5s %4s%4s %s'+crlf,[tmpnum+1,
                                  copy(Date.strings[tmpnum],length(Date.strings[tmpnum])-4,5),count.strings[tmpnum],pages.strings[tmpnum],copy(IndexByTitle.strings[tmpnum],1,56)]);
          end;
          dec(next);
       end;
       SendStr:=LineMessage;
       repeat
             Sendstr:=' 명령어안내(C) 초기화면(T) 작성(W,E,D) 이동(GO,P,B) 쪽지(TO) 종료(X,Bye)'+crlf+' 선택> ';
             cmdinput(tmpinput[1],tmpinput[2],tmpinput[3],false);
             if commonfunc(tmpinput[1],tmpinput[2],tmpinput[3],true)=1 then
                exit;

             if terminated then exit;
             if tmpinput[1]='c' then begin
                sendstr:=' 글쓰기 W   글지우기 D[번호]   이전페이지 B'+CRLF;
                sendstr:=' 제목으로 검색 LT [제목] 아이디로 검색 LI [아이디] '+crlf;
                sendstr:=' 이름으로 검색 LN [이름] 지정게시물번호부터 보기 LS [번호]'+CRLF+crlf;
             end;
             if tmpinput[1]='' then begin
                if Next>=0 then begin
                  View:=Next;
                  break;
                end else
                    sendStr:='더이상 없습니다.'+crlf+crlf;
             end;
             if tmpinput[1]='ls' then begin
                try
                   tmpnum:=strtoint(tmpinput[2]);
                except
                      tmpnum:=-1;
                end;
                boardindex.Clear;
                view:=-1;
                for i:=0 to MyPos.Board.CanAccess.Count-1 do begin
                    if MyPos.Board.CanAccess[i]<>'*' then begin
                       boardIndex.Add(inttostr(i));
                    end;
                    if tmpnum>i then begin
                       View:=boardindex.count-1;
                    end;
                end;
                if view=-1 then
                   view:=boardindex.count-1;
                Next:=view;
                break;
             end;

             if tmpinput[1]='lt' then begin
              if length(tmpinput[2])>=2 then begin
                boardindex.Clear;
                view:=-1;
                for i:=0 to MyPos.Board.CanAccess.Count-1 do begin
                    if MyPos.Board.CanAccess[i]<>'*' then begin
                       if pos(tmpinput[2],mypos.Board.IndexByTitle[i])>0 then
                          boardIndex.Add(inttostr(i));
                    end;
                end;
                view:=boardindex.count-1;
                Next:=view;
                break;
              end else begin
                  sendstr:=' 검색어는 최소한 두글자 이상이 되어야 합니다. '+crlf;
              end;
             end;

             if (tmpinput[1]='li') and (kind<2) then begin
              if length(tmpinput[2])>=2 then begin
                boardindex.Clear;
                view:=-1;
                for i:=0 to MyPos.Board.CanAccess.Count-1 do begin
                    if MyPos.Board.CanAccess[i]<>'*' then begin
                       if pos(tmpinput[2],mypos.Board.IndexByID[i])>0 then
                          boardIndex.Add(inttostr(i));
                    end;
                end;
                view:=boardindex.count-1;
                Next:=view;
                break;
              end else begin
                  sendstr:=' 검색어는 최소한 두글자 이상이 되어야 합니다. '+crlf;
              end;
             end;

             if tmpinput[1]='ln' then begin
              if length(tmpinput[2])>=2 then begin
                boardindex.Clear;
                view:=-1;
                for i:=0 to MyPos.Board.CanAccess.Count-1 do begin
                    if MyPos.Board.CanAccess[i]<>'*' then begin
                       if pos(tmpinput[2],mypos.Board.Name[i])>0 then
                          boardIndex.Add(inttostr(i));
                    end;
                end;
                view:=boardindex.count-1;
                Next:=view;
                break;
              end else begin
                  sendstr:=' 검색어는 최소한 두글자 이상이 되어야 합니다. '+crlf;
              end;
             end;

             if tmpinput[1]='b' then begin
                found:=0;
                tmpview:=next;
                next:=view;
                while (next<boardindex.count-1) and (found<=15) do begin
                      inc(next);
                      inc(found);
                end;
                if found>1 then begin
                   view:=next;
                   break;
                end else begin
                    next:=tmpview;
                end;
             end;

             if tmpinput[1]='z' then begin
                next:=view;
                break;
             end;

             if tmpinput[1]='d' then begin
              try
                if strtoint(tmpinput[2])=strtoint(inttostr(strtoint(tmpinput[2]))) then begin
                   if (strtoint(tmpinput[2])>0) and(strtoint(tmpinput[2])<=mypos.board.canaccess.count) then
                      if (mypos.board.indexbyid[strtoint(tmpinput[2])-1]=id) or
                         (mypos.isadmin(id)) then begin
                         sendstr := '지우시겠습니까? (y/N) ';
                         if lowercase(input)='y' then begin
                            mypos.board.canaccess.strings[strtoint(tmpinput[2])-1]:='*';
                            tmpstr:=tstringlist.create;
                            tmpstr.LoadFromFile(mypos.dir+'\'+tmpinput[2]+'.txt');
                            tmpstr.strings[0]:='*';
                            tmpstr.savetofile(mypos.dir+'\'+tmpinput[2]+'.txt');
                            tmpstr.free;
                            sendstr := '삭제하였습니다.'+crlf;
                            logwrite(MyPos.Name+'('+MyPos.Index+')에서 '+tmpinput[2]+'번 글 삭제');
                         end;
                      end else begin
                         sendstr := '권한이 없습니다.'+crlf+crlf;
                      end;
                end;
              except
              end;
             end;
             if tmpinput[1]='w' then begin
                try
                  if (kind=1) and (not Mypos.isadmin(id)) then begin
                     sendstr:='쓰기는 허용되지 않습니다.'+crlf;
                     raise exception.create('쓰기불가');
                  end;
                  SendStr:=ClearScr+TopMessage+' '+Mypos.Index+MidPrt(MyPos.Name)+LineMessage;
                  repeat
                      SendStr:=' 제목 : ';
                      title:=Input;
                      if length(title)<4 then begin
                         SendStr:='제목은 4자 이상이어야 합니다.'+crlf+crlf;
                         SendStr:='취소하시겠습니까? (Y/n) ';
                         if lowercase(input)<>'n' then begin
                            raise exception.create('작성취소함');
                         end;
                      end;
                  until length(title)>=4;
                  SendStr:= '내용을 입력해 주십시오. 끝내시려면 ''.''을 치십시오.'+crlf;
                  SendStr:=dotline;
                  tmptext:='';
                  lines:=0;
                  repeat
                      tmp:=input;
                      if tmp<>'.' then begin
                         tmptext:=tmptext+tmp+crlf;
                         inc(lines);
                      end;
                  until tmp='.';

                  SendStr:='등록하시겠습니까? (Y/n) ';
                  tmp:=lowercase(input);

                  if tmp<>'n' then begin
                     writetoboard(title,tmpnum,lines);
                     mypos.board.canaccess.Strings[tmpnum]:=' ';
                     assign(file1,mypos.dir+'\'+inttostr(tmpnum+1)+'.txt');
                     rewrite(file1);
                     writeln(file1,' ');
                     writeln(file1,title);
                     writeln(file1,id);
                     writeln(file1,myname);
                     writeln(file1,datetostr(date));
                     writeln(file1,timetostr(time));
                     writeln(file1,'0');
                     writeln(file1,inttostr((lines div 14)+1));
                     write(file1,tmptext);
                     closefile(file1);
                     sendstr:='등록되었습니다.'+crlf;
                     logwrite(MyPos.Name+'('+MyPos.Index+')에서 글 작성');
                  end;

                boardindex.Clear;
                for i:=0 to MyPos.Board.CanAccess.Count-1 do begin
                    if MyPos.Board.CanAccess[i]<>'*' then begin
                       boardIndex.Add(inttostr(i));
                    end;
                end;
                view:=boardindex.count-1;
                Next:=view;

                break;

                except
                end;
             end;

             try
                if strtoint(tmpinput[1])=strtoint(inttostr(strtoint(tmpinput[1]))) then begin
                  lines:=strtoint(tmpinput[1]);
                  repeat
                   TmpStr:=TStringList.Create;
                   if (lines>mypos.board.canaccess.count) or (lines<1)then
                      raise exception.create('..-_-;')
                   else
                       if mypos.board.canaccess.strings[lines-1]='*' then
                          raise exception.creatE('못읽는게시물');
                   TmpStr.LoadFromFile(mypos.dir+'\'+inttostR(lines)+'.txt');
                   Tmpstr.strings[6]:=inttostr(strtoint(Tmpstr.strings[6])+1);
                   TmpStr.SaveToFile(mypos.dir+'\'+inttostR(lines)+'.txt');
                   Mypos.board.count.Strings[lines-1]:=inttostr(strtoint(Tmpstr.strings[6]));
                   ViewLines:=1;
                   NowLines:=1;
                   repeat
                      Sendstr:=ClearScr+TopMessage+' '+Mypos.Index+MidPrt(MyPos.Name)+LineMessage;
                      SendStr:=' 제 목  : '+TmpStr[1]+crlf;
                      SendStr:=format(' 올린이 : %-8s(%-8s)   %s %s   읽음 : %s   %d/%s'+crlf,[tmpstr[2],tmpstr[3],tmpstr[4],tmpstr[5],tmpstr[6],(viewlines div 14)+1,tmpstr[7]]);
                      SendStr:=dotline;
                      repeat
                           if viewlines+7<tmpstr.count then
                               SendStr:=TmpStr[7 +viewlines]+crlf
                           else
                               Break;
                            if viewlines-nowlines>12 then break;
                          inc(viewlines);
                      until terminated;
                      SendStr:=linemessage;
                      repeat
                            Sendstr:=' 명령어안내(C) 초기화면(T) 이동(GO,P,N,A,B) 쪽지(TO) 종료(X,Bye)'+crlf+' 선택> ';
                            cmdinput(tmpinput[1],tmpinput[2],tmpinput[3],false);
                            if tmpinput[1]='z' then begin
                               viewlines:=NowLines;
                               break;
                            end;

                            if tmpinput[1]='n' then begin
                               tmpnum:=lines-1;
                               if tmpnum>0 then
                                 while (mypos.board.canAccess[tmpnum-1]='*') do begin
                                       dec(tmpnum);
                                       if tmpnum<1 then break;
                                 end;
                               if tmpnum>0 then begin
                                  lines:=tmpnum;
                                  break;
                               end else begin
                                   sendstr:=' 제일 처음의 게시물입니다.'+crlf;
                                   continue;
                               end;
                            end;

                            if tmpinput[1]='a' then begin
                               tmpnum:=lines+1;
                               if tmpnum<=mypos.board.canaccess.count then
                                 while (mypos.board.canAccess[tmpnum-1]='*') do begin
                                       inc(tmpnum);
                                       if tmpnum>mypos.board.canaccess.count then break;
                                 end;
                               if tmpnum<=mypos.board.canaccess.count then begin
                                  lines:=tmpnum;
                                  break;
                               end else begin
                                   sendstr:=' 마지막 게시물입니다.'+crlf;
                                   continue;
                               end;
                            end;


                            if tmpinput[1]='b' then begin
                               nowlines:=nowlines-14;
                               if nowlines<1 then nowlines:=1;
                               viewlines:=nowlines;
                               break;
                            end;
                            if tmpinput[1]='p' then begin
                               next:=view;
                               break;
                            end;
                            if tmpinput[1]='' then begin
                               if viewlines+7>=tmpstr.count then begin
                                  sendstr:=' 더이상 없습니다.'+crlf+crlf;
                                  continue;
                               end else begin
                                   nowlines:=nowlines+14;
                                   viewlines:=nowlines;
                                   break;
                               end;
                            end;
                            try
                             if strtoint(tmpinput[1])=strtoint(inttostr(strtoint(tmpinput[1]))) then begin
                               nowlines:=(strtoint(tmpinput[1])-1)*14+1;
                               if nowlines<1 then nowlines:=1;
                               if nowlines+7>tmpstr.Count then begin
                                  sendstr:=' 그런 페이지는 없습니다.'+crlf+crlf;
                                  nowlines:=viewlines-13;
                                  if nowlines<1 then nowlines:=1;
                               end else begin
                                   viewlines:=nowlines;
                                   break;
                               end;
                             end;
                            except
                            end;

                            if commonfunc(tmpinput[1],tmpinput[2],tmpinput[3],true)=1 then exit;
             if tmpinput[1]='c' then begin
                               sendstr:=' 앞게시물 A 뒷게시물 N'+crlf+crlf;
             end;


                      until false;
                      if (tmpinput[1]='p') or ((tmpinput[1]='a') or (tmpinput[1]='n')) then
                               break;
                   until false;
                   TmpStr.free;
                   if (tmpinput[1]='p') then
                      break;
                  until false;
                  if (tmpinput[1]='p') then
                     break;

               end;
             except
             end;

       until terminated;
     until terminated;
end;

function TUser.ReceiveMessage(from,fromname,text:string):boolean;
var i:integer;
begin
  sendstr:=esc+'7'+esc+'[24;2H'+esc+'[K'+from+'('+fromname+') => '+ic+text+uic+esc+'8';
  Receivemessage:=true;
  for i:=12 downto 2 do
      provmsg[i]:=provmsg[i-1];
  self.provmsg[1]:=from+'('+fromname+') => '+text;
  if sendbeep then
     sendstr:=chr(7);
end;

procedure TUser.MessageTo(who,text:string);
var i:integer;
    b:boolean;
begin
     who:=lowercase(who);
     if text='' then exit;
     if who='' then exit;
     for i:=1 to MaxUser do begin
         if userlist[i]<>nil then
           try
            if userlist[i].id=who then begin
               b:=userlist[i].Receivemessage(id,myname,text);
               if b=false then
                   sendstr:=' '+who+' 님은 접속중이 아니거나 수신불가상태입니다. '+crlf
               else
                   sendstr:=' '+who+'(pts/'+inttostR(userlist[i].pts)+')님께 메세지를 보냈습니다.'+crlf;
               end;
           except
                 sendstr:=' 객체참조 오류입니다.';
           end;

     end;
end;

procedure TUser.User;
var i:integer;
    k:integer;
    tmpstr:string;
begin
     k:=0;
     tmpstr:='-------접속자목록-------'+crlf;
     for i:=1 to MaxUser do
       try
         if assigned(userlist[i]) then begin
            inc(k);
            tmpstr:=tmpstr+userlist[i].id+'('+userlist[i].myname+'), pts/'+inttostr(userlist[i].pts)+crlf;
         end;
       except
       end;

     sendstr:=tmpstr+'------------------------'+crlf;
end;

procedure TUser.Msgr;
var i:integer;
begin
   for i:=1 to 12 do
     if provmsg[i]<>'' then sendstr:=provmsg[i]+crlf;
end;

procedure TUser.Msgb;
var i:integer;
begin
     if sendbeep then begin
        sendstr:=' 쪽지받을때 소리를 내지 않습니다. '+crlf;
        sendbeep:=false;
     end else begin
        sendstr:=' 쪽지받을때 소리를 냅니다. '+crlf;
        sendbeep:=true;
     end;

end;

function TUser.commonfunc(str1,str2,str3:string;canmove:boolean):integer;
var num,i:integer;
begin

  commonfunc:=0;
                str1:=lowercase(str1);
             if STR1='c' then begin
                sendstr:=' 초기화면 T     이동 GO [INDEX]       예) go board'+crlf;
                sendstr:=' 상위메뉴 P     쪽지 TO [ID] [할말]   예) to innoboy 메롱'+crlf;
                sendstr:=' 지난쪽지 MSGR  쪽지소리 MSGB  프로필 PF [ID] 시간 TIME 메모 MEMO [ID] [할말]'+CRLF;
                sendstr:=' 접속끊기 BYE,X 관리자보기 ADMIN 서버정보 INFO 로그보기 LOG [볼 갯수]'+crlf+crlf;
                exit;
             end;

             if str1='log' then begin
                num:=20;
                try
                   num:=strtoint(str2);
                except
                end;
                num:=LogBox.Items.Count-num;
                if num<0 then num:=0;
                for i:=num to LogBox.Items.Count-1 do begin
                    sendstr:=logbox.items[i]+crlf;
                end;

             end;

             if str1='info' then begin
                  SendStr:=crlf+' EasyBBS builder BUILD '+inttostr(buildnum)
                  +', 플랫폼 '+WindowsVersion+crlf+' 개발자 E-Mail : innoboy@nownuri.net. '+crlf+' 이 버젼의 최대 동시접속자 수는 '+inttostr(MaxUser)+'명으로 제한되어 있습니다.'+crlf+crlf;
             end;

             if str1='x' then begin
                commonfunc:=1;
                sendstr:=' 정말 끝내시겠습니까? (Y/other)';
                if lowercase(input)='y' then begin
                   free;
                end;
                exit;
             end;

         if canmove then begin
             if str1='t' then begin
                commonfunc:=1;
                mypos:=topnode;
                exit;
             end;
             if str1='p' then begin
                if mypos.parent<>nil then mypos:=mypos.parent;
                commonfunc:=1;
                exit;
             end;
             if str1='go' then begin
                if go(str2) then begin
                   commonfunc:=1;
                   exit;
                end;
             end;
         end;

             if str1='admin' then begin
                adminlist;
                exit;
             end;
             if str1='pf' then begin
                profile(str2);
                exit;
             end;

             if str1='memo' then begin
                writememo(str2,str3);
                exit;
             end;
             if str1='time' then begin
                sendtime;
                exit;
             end;

             if str1='to' then begin
                messageto(str2,str3);
                exit;
             end;
             if str1='user' then begin
                user;
                exit;
             end;
             if (lowercase(str1+str2)='msgr') then
                msgr;
             if (lowercase(str1+str2)='msgb') then
                msgb;
             if str1='bye' then begin
                free;
                exit;
             end;
  commonfunc:=-1;
end;

procedure TUser.MotherMenu;
var tmpinput:array[1..3] of string;
    tmpstr:tstringlist;
    i:integer;
begin
       Sendstr:=ClearScr+TopMessage+' '+Mypos.Index+MidPrt(MyPos.Name)+LineMessage;

       try
         if fileexists(Mypos.Dir+'\menu.txt') then begin
            tmpstr:=tstringlist.create;
            tmpstr.LoadFromFile(mypos.dir+'\menu.txt');
            sendstr:=tmpstr.text;
            tmpstr.free;
         end else
             raise exception.create('메뉴파일 없음');
       except
           for i:=1 to mypos.childcount do
               sendstr:=Mypos.child[i].choiceindex+'. '+Mypos.child[i].name+crlf+crlf;
       end;

       sendstr:=LineMessage;
       repeat
             Sendstr:=' 명령어안내(C) 초기화면(T) 이동(GO,P) 쪽지(TO) 종료(X,Bye)'+crlf+' 선택> ';
             cmdinput(tmpinput[1],tmpinput[2],tmpinput[3],false);
             if commonfunc(tmpinput[1],tmpinput[2],tmpinput[3],true)=1 then
                exit;
             if tmpinput[1]='z' then exit;
             if terminated then exit;
             for i:=1 to mypos.childcount do
                 if mypos.child[i].choiceindex=tmpinput[1] then begin
                    mypos:=mypos.child[i];
                    try
                       if fileexists(Mypos.Dir+'\premenu.txt') then begin
                          tmpstr:=tstringlist.create;
                          tmpstr.LoadFromFile(mypos.dir+'\premenu.txt');
                          sendstr:=ClearScr+tmpstr.text;
                          sendstr:=Esc+'[20;4H[Enter]를 누르십시오.';
                          input;
                          tmpstr.free;
                       end;
                    except
                    end;
                    exit;
                 end;
       until terminated;
end;

procedure TUser.Guest;
var tmpinput,Name,Pass,RePass,Job,Address,Telephone,BP,Handphone:String;
    comment:array[1..3] of string;
    i,tmphandle:integer;
    file1:textfile;
begin
     id:='GUEST';
     SendStr:=TopMessage+MIDPRT('가입신청')+LineMessage;
     SendStr:=GuestMessage;
     SendStr:='* 이름을 입력해 주십시오.'+crlf+'  한글 두자 이상 네자 이내여야 합니다.  공백은 입력하지 말아주십시오.'+crlf+'    맞는예) 홍길동, 신안..  틀린예)가, 홍 길동..'+crlf+crlf;
     repeat
           SendStr:='이름 : ';
           Name:=Input;
           if (length(Name)<4) or (length(Name)>8) then begin
              Sendstr:='이름은 한글 두자 이상 네자 이하여야 합니다.'+Crlf;
              continue;
           end;
           if pos(' ',Name)>0 then begin
              Sendstr:='공백없이 입력해 주십시오.'+crlf;
              continue;
           end;
           sendstr:='이름이 맞습니까?(y/N) ';
           if lowercase(input)='y' then break;
     until terminated;

     tmphandle:=0;

     SendStr:=Crlf+crlf+'* 아이디를 입력해 주십시오.'+crlf+'  아이디는 한글 두자 이상 네자 이내, 영문(또는 숫자) 네자 이상 여덟자 이내이어야 합니다.'+crlf+crlf;
     repeat
           SendStr:='아이디 : ';
           TmpID:=input;
           if pos(' ',tmpid)>0 then begin
              sendstr:='아이디에 공백이 들어가서는 안됩니다.';
              continue;
           end;
           if length(TmpID)<4 then BEGIN
              sendstr:='아이디는 한글 두자 이상 네자 이내, 영문(또는 숫자) 네자 이상 여덟자 이내이어야 합니다.'+crlf+crlf;
              continue;
           end;
           tmphandle:=createfile(pchar(ExeDir+'userdata\'+TmpID+'.ID'),generic_write,0,nil,CREATE_NEW,FILE_ATTRIBUTE_NORMAL,0);
           if TmpHandle=-1 then begin
              closehandle(tmphandle);
              SendStr:='이미 존재하는 아이디이거나 잘못된 ID입니다.'+crlf
           end else begin
               closehandle(tmphandle);
               break;
           end;

     until (length(tmpID)>=4) and (TmpHandle>0);
     id:='guest';
     repeat
         echo_star:=true;
           SendStr:=CRLF+'비밀번호 : ';
           Pass:=Input;
         if length(pass)<4 then begin
            sendstr:='비밀번호는 4자 이상이어야 합니다.'+crlf;
            continue;
         end;
           SendStr:=CRLF+'확인을 위해 한번 더 입력해 주십시오 : '+IAC+WILL+ECHO;
           RePass:=Input;
           if Pass<>RePass then
              SendStr:=CRLF+'비밀번호가 틀립니다. 다시 입력해 주십시오.'+CRLF+CRLF;
     until Pass=RePass;
     echo_star:=false;

     SendStr:=crlf+crlf+'* 생년월일을 입력해 주십시오 '+CRLF+'    예) 1999/02/19'+CRLF;
     repeat
           sendstr:='생년월일 : ';
           birthdate:=input;
           sendstr:='입력하신 생일이 맞습니까? (Y/n)';
           tmpinput:=UPPERCASE(input);
     until tmpinput<>'N';

{     SendStr:=crlf+crlf+'* 주민등록번호를 입력해 주십시오. 규칙에 맞게 입력해야 합니다.'+CRLF+'    예) 123456-1234563'+CRLF;
     repeat
           SendStr:=CRLF+'주민등록번호 : ';
           tmpinput:=Input;
           if tmpinput='123456-1234563' then continue;
           if Length(tmpinput)<>14 then continue;
           for i:=1 to 6 do
               if (tmpinput[i]<'0') or (tmpinput[i]>'9') then continue;
           if tmpinput[7]<>'-' then continue;
           for i:=8 to 14 do
               if (tmpinput[i]<'0') or (tmpinput[i]>'9') then continue;

//           tmphandle:=createfile(pchar(ExeDir+'userdata\regnum\'+tmpinput),generic_write,0,nil,CREATE_NEW,FILE_ATTRIBUTE_NORMAL,0);
              closehandle(tmphandle);
            if TmpHandle=-1 then begin
              SendStr:='이 주민등록번호는 사용되고 있습니다.'+crlf;
              continue;
           end else
           begin
              RegNum:=TmpInput;

              if strtoint(RegNum[14])=(11-( (strtoint(RegNum[1])*2+
              strtoint(RegNum[2])*3+
              strtoint(RegNum[3])*4+
              strtoint(RegNum[4])*5+
              strtoint(RegNum[5])*6+
              strtoint(RegNum[6])*7+
              strtoint(RegNum[8])*8+
              strtoint(RegNum[9])*9+
              strtoint(RegNum[10])*2+
              strtoint(RegNum[11])*3+
              strtoint(RegNum[12])*4+
              strtoint(RegNum[13])*5) mod 11)) MOD 10 then
                                   break;
           end;
     until terminated;}

     sendstr:=crlf+crlf+'* 소속이나 직장을 입력해 주십시오. '+crlf+crlf;
     repeat
           sendstr:='소속 : ';
           JOB:=input;
           sendstr:='입력하신 것이 맞습니까? (Y/n)';
           tmpinput:=UPPERCASE(input);
     until tmpinput<>'N';

     sendstr:=crlf+crlf+'* 주소를 입력해 주십시오. '+crlf+crlf;
     repeat
           sendstr:='주소 : ';
           ADDRESS:=input;

           sendstr:='입력하신 주소가 맞습니까? (Y/n)';
           tmpinput:=UPPERCASE(input);
     until tmpinput<>'N';

     sendstr:=crlf+crlf+'* 전화번호를 입력해 주십시오. '+crlf+crlf;
     repeat
           sendstr:='전화번호 : ';
           Telephone:=input;
           sendstr:='입력하신 전화번호가 맞습니까? (Y/n)';
           tmpinput:=UPPERCASE(input);
     until tmpinput<>'N';

     sendstr:=crlf+crlf+'* 삐삐번호를 입력해 주십시오.  없으실 경우 비워두십시오.'+crlf+ '  이동전화를 가지고 계신 경우에는 다음 란에 기입해 주시기 바랍니다.'+crlf+crlf;
     repeat
           sendstr:='삐삐번호 : ';
           BP:=input;

           sendstr:='입력하신 삐삐번호가 맞습니까? (Y/n)';
           tmpinput:=UPPERCASE(input);

     until tmpinput<>'N';

     sendstr:=crlf+crlf+'* 이동전화 번호를 입력해 주십시오.  없으실 경우 비워두십시오.'+crlf+crlf;
     repeat
           sendstr:='이동전화 번호 : ';
           handphone:=input;

           sendstr:='입력하신 전화번호가 맞습니까? (Y/n)';
           tmpinput:=UPPERCASE(input);

     until tmpinput<>'N';
     sENDsTR:=IAC+WONT+ECHO;

     sendstr:=crlf+crlf+'* 다른 이용자들에게 할 말을 적어주십시오. 3줄입니다.'+crlf+crlf;
     repeat
           sendstr:=' 1 - ';
           comment[1]:=input;
           if terminated then exit;
           sendstr:=' 2 - ';
           comment[2]:=input;
           if terminated then exit;
           sendstr:=' 3 - ';
           comment[3]:=input;
           if terminated then exit;

           sendstr:='입력하신 내용이 맞습니까? (Y/n)';
           tmpinput:=UPPERCASE(input);
     until tmpinput<>'N';

     priority:=tpTimeCritical;
     assignfile(file1, exedir+'userdata\'+tmpid+'.dat');
     rewrite(file1);
     writeln(file1,pass);
     writeln(file1,name);
     writeln(file1,birthdate);
     writeln(file1,job);
     writeln(file1,address);
     writeln(file1,telephone);
     writeln(file1,bp);
     writeln(file1,handphone);
//     inc(totuser);
//     writeln(file1,inttostr(totuser));

     writeln(file1,0);  // 접속횟수 -> 가입 신청 완료되었나?

     writeln(file1,comment[1]);
     writeln(file1,comment[2]);
     writeln(file1,comment[3]);
     closefile(file1);

     if (not isfree) then begin
             assignfile(file1, exedir+'userdata\'+tmpid+'.wat');
             rewrite(file1);
             writeln(file1,'waiting..');
             closefile(file1);
     end;

     id:='GUEST';

     if (isfree) then begin
             sendstr:='가입처리가 완료되었습니다. 이제 이 BBS를 사용하실 수 있습니다.'+CRLF;
     end else begin
                sendstr:='가입신청이 완료되었습니다. 시삽이 가입확인후 BBS를 사용하실 수 있습니다.'+CRLF+'문의사항이 있으시면 시삽에게 연락하십시오.'+CRLF;
     end;
end;

procedure TUser.SendMsg(SrcString: string);
begin
     send(sockid,srcstring[1],length(Srcstring),0);
//        free;
end;

function TUser.Input:String;
var i:integer;
    ttmp:string;
    echostr:string;
begin
     lastinputtime:=timegettime;
     repeat
        echostr:='';
        repeat
           ttmp:=readmsg;
           if ttmp<>'' then begin
              lastinputtime:=timegettime;
              danger:=false;
           end else begin
                   if timegettime-lastinputtime>240000 then begin
                      if not danger then
                         Receivemessage('','경고','5분동안 입력이 없을경우 접속을 해제합니다. (현재 '+ inttostr( (timegettime-lastinputtime) div 1000)+ '초 경과)'+crlf);
                      danger:=true;
                   end;
                   if timegettime-lastinputtime>300000 then begin
                      sendstr:='5분동안 입력이 없으므로 접속을 끊습니다.'+crlf;
                      free;
                   end;
                   if bufferstr='' then suspend;
           end;
        until ttmp+bufferstr<>'';

           for i:=1 to length(ttmp) do begin
               if ttmp[i]=chr(vk_back) then begin
                  if length(bufferstr)>0 then begin
                     bufferstr:=copy(bufferstr,1,length(bufferstr)-1);
                     echostr:=echostr+chr(vk_back)+' '+chr(vk_back);
                  end;
               end else begin
                   if echo_star then begin
                      if ttmp[i]<>chr(13) then echostr:=echostr+'*' else
                         echostr:=echostr+chr(13);
                   end else
                       echostr:=echostr+ttmp[i];
                   bufferstr:=bufferstr+ttmp[i];
                   if ttmp[i]=chr(13) then echostr:=echostr+chr(10);
               end
           end;
           if echostr<>'' then sendstr:=echostr;
           for i:=1 to length(Bufferstr) do
               if ord(Bufferstr[i])=13 then begin
                  if i>=1 then
                     Input:=copy(Bufferstr,1,i-1)
                  else
                      input:='';
                  if i<length(Bufferstr) then
                     Bufferstr:=copy(Bufferstr,i+1,length(Bufferstr)-i)
                  else
                      bufferstr:='';
                  exit;
               end;
           if ttmp='' then suspend;
     until terminated;
end;

function TUser.ReadMsg:string;
var tmp:array[1..4096] of char;
    i:integer;
    tmps:string;
    tmpn:integer;
begin
     tmpn:=recv(sockid,tmp[1],4000,0);
     for i:=1 to tmpn do begin
         if tmp[i]=iac then begin
            ignore:=2;
            continue;
         end;
         if ignore>0 then begin
            dec(ignore);
            continue;
         end;
         if tmp[i]=chr(10) then continue;
         prechar:=tmp[i];
         if tmp[i]=chr(27) then continue;
         if tmp[i]=chr(0) then continue;
         tmps:=tmps+tmp[i];
     end;
     readmsg:=tmps;
end;

procedure adduser(socketid:integer;ipaddr:integer);
var i:integer;
    tmpstr:pchar;
    wait:integer;

begin
  try
     for i:=1 to MaxUser do begin
         if userlist[i]=nil then begin
            FrmConnection.TotalUser:=FrmConnection.TotalUser+1;
            userlist[i]:=Tuser.create(true);
            userlist[i].init(socketid,ipaddr,cttelnet);
            userlist[i].pts:=i;
            userlist[i].priority:=tpLowest;
            userlist[i].ulid:=i;
            userlist[i].listitem:=mainform.ListView1.Items.Add;
            userlist[i].listitem.data:=userlist[i];
            userlist[i].listitem.Caption:='접속중';
            userlist[i].listitem.SubItems.add('');
            userlist[i].listitem.SubItems.add(iptostr(ipaddr));
            userlist[i].listitem.SubItems.add(timetostr(time));
//            ('접속중 , IP : '+iptostr(ipaddr),userlist[i]);
            userlist[i].resume;
            exit;
         end;
     end;
//  setsockopt(SocketID,IPPROTO_TCP,so_dontlinger,nil,0);
  except
     tmpstr:=' 죄송합니다. 에러입니다. 잠시 후 접속해주시기 바랍니다.'+crlf;
     send(socketid,tmpstr[1],length(tmpstr),0);
     wait:=timegettime;
{     repeat
     until timegettime-wait>100;}
     closesocket(socketid);
     exit;
  end;
     tmpstr:=' 죄송합니다. 현재 사용자가 많아 연결하지 못했습니다.'+crlf+'잠시 후 접속해주시기 바랍니다.'+crlf;
     send(socketid,tmpstr[1],length(tmpstr),0);
{     wait:=timegettime;
     repeat
     until timegettime-wait>100;}
     closesocket(socketid);
end;

function userconnected(id:string):boolean;
var i:integer;
begin
     for i:=1 to MaxUser do begin
         if userlist[i]<>nil then
           try
            if (userlist[i].id=id) then begin
               userconnected:=true;
               exit;
            end;
           except
           end;
     end;
     userconnected:=false;
end;

procedure executeuser(socketid:integer);
var i:integer;
begin
     for i:=1 to MaxUser do begin
         if userlist[i]<>nil then
           try
            if (userlist[i].sockid=socketid) then begin
               try
                  //if userlist[i].suspended then
                  userlist[i].resume;
               except
               end;
               break;
            end;
           except
           end;
     end;
end;

procedure closeall;
var i:integer;
begin
     for i:=1 to MaxUser do begin
         if userlist[i]<>nil then begin
            try
               userlist[i].suspend;
               userlist[i].free;
            except
            end;
               userlist[i]:=nil;
         end;
     end;
end;
procedure deleteuser(socketid:integer);
var i:integer;
begin
     for i:=1 to MaxUser do begin
         if userlist[i]<>nil then
           try
            if userlist[i].sockid=socketid then begin
               try
                 userlist[i].suspend;
                 userlist[i].free;
               except
               end;
               userlist[i]:=nil;

            end;
           except
           end;
     end;
end;

end.
