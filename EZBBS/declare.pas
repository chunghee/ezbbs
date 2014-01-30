unit Declare;

interface
uses
    classes,sysutils;
const MaxUser=100;
      Index_Login=0;
      CRLF = CHR(13)+CHR(10);
      BuildNum = 49;
      IAC = CHR(255);
      WILL = CHR(251);
      WONT = CHR(252);
      doo  = chr(253);
      DONT = CHR(254);
      ECHO = CHR(1);
      ESC = CHR(27);
      ClearScr=ESC+'[2J'+ESC+'[1;1H';
      IC = ESC+'[7m';
      UIC = ESC+'[27m';
      K_MotherMenu=0;
      K_Board=1;
      K_Chat=2;
      K_Rmail=3;
      K_Wmail=4;
      k_EditMyData=5;
      k_Notice=6;
      k_Hidden=7;
      Speech:Boolean=True;
      IsFree:Boolean=True;
      RunBind:Boolean=True;
      RunHide:Boolean=False;
      MultiLogin:Boolean=False;
      BBSNAME:string='EASY BBS';
      telnetport:integer=23;
      httpport:integer=80;
      GuestMessage:sTRING=' -- 손님은 가입만 할 수 있습니다. --' + CRLF;
      LoginMessage:string = ' 이 BBS에 오신 것을 환영합니다.'+CRLF;
      LineMessage:string =' ───────────────────────────────────────'+crlf;
      dotline:string=' ------------------------------------------------------------------------------'+crlf;

type  TBoard=class
        IndexByID:TStringList;
        IndexByTitle:TStringList;
        Date:TStringList;
        Name:TStringList;
        time:TStringList;
        pages:TStringList;
        Count:TStringList;
        CanAccess:TStringlist;
      end;
      TChat=class
        Title:String;
        Kind:integer;
        Pass:string;
        Master:pointer;
        totaluser:integer;
        nowuser:integer;
        Users:array[1..12] of pointer;
      end;
      TChatRoom=class
        Rooms:array[1..999] of TChat;
        Waiting:array[1..MaxUser] of Pointer;
      end;
      PAdminList=^TAdminList;
      TAdminList=record
                       id:string;
                       next:PAdminList;
      end;
      TData=record
                  data:pointer;
                  size:integer;
      end;
      TMyTreeNode=class
                      index:string;
                      choiceindex:string;
                      name:string;
                      kind:integer;
                      dir:string;
                      childcount:integer;
                      adminlist:TAdminList;
                      child:array[1..255] of TMyTreeNode;
                      parent:TMyTreeNode;
                      prov:TMyTreeNode;
                      next:TMyTreeNode;
                      chat:TChatRoom;
                      board:TBoard;
//                      menutxt:tstringlist;
//                      premenutxt:tstringlist;
                      function isadmin(id:string):boolean;
                      procedure addtoadmin(id:string);
//                      procedure removefromadmin(id:string);
                      constructor Create;
                      destructor Destroy; override;

                  private
                  public
                      function addchild:TMyTreeNode;
                      procedure SortChildrenByChoiceIndex;
     end;
     pindex=^tindex;
     tindex=record
               menu:TMyTreeNode;
               next:pindex;
     end;

var exedir:string;
    windowsversion:string;
    headindex:pindex;
    topnode:tmytreenode;
    totuser:integer;
    emotion:TStringlist;

    tplogo:tdata;
    tplogon:tdata;
    imglogo1:tdata;
    imglogo2:tdata;
    tpguest:tdata;

function topmessage:string;
implementation
function topmessage:string;
begin
  if length(bbsname) mod 2 =0 then begin
      TopMessage:=ClearScr+
      ' ─────────────────────────────────────── '+crlf
   +ESC+'[1;2H'+IC+BBSNAME+UIC+CRLF;
  end
  else begin
      TopMessage:=ClearScr+
      ' ─────────────────────────────────────── '+crlf
   +ESC+'[1;2H'+IC+BBSNAME+UIC+' '+CRLF;
  end;


end;

function TMyTreeNode.isadmin(id:string):boolean;
var find:PAdminList;
    pos:TMyTreeNode;
begin
     find:=adminlist.next;
     pos:=self;
     repeat
           if find=nil then begin
              if pos.parent<>nil then begin
                 pos:=pos.parent;
                 find:=pos.adminlist.next;
              end else begin
                   IsAdmin:=false;
                   exit;
              end;
           end else begin
               if find^.id=id then begin
                  isadmin:=true;
                  exit;
               end;
               find:=find^.next;
           end;
     until false;
     isadmin:=true;
end;

procedure TMyTreeNode.addtoadmin(id:string);
var
    newlist:PAdminList;
begin
    new(newlist);
    newlist.id:=id;
    newlist.next:=adminlist.next;
    adminlist.next:=newlist;
end;

constructor TMyTreeNode.Create;
begin
//     new(
end;

destructor TMyTreeNode.Destroy;
var i:integer;
begin
     for i:=1 to childcount do
         child[i].destroy;
//     if assigned(Menutxt) then
//        Menutxt.destroy;
//     if assigned(PreMenutxt) then
//        PreMenutxt.destroy;

     inherited;
end;
procedure TMyTreeNode.SortChildrenByChoiceIndex;
var i,j:integer;
    tmptreenode:tmytreenode;
begin
     for i:=1 to childcount do
         for j:=i+1 to childcount do
           try
             if strtoint(child[i].choiceindex)>strtoint(child[j].choiceindex) then begin
                tmptreenode:=child[i];
                child[i]:=child[j];
                child[j]:=tmptreenode;
             end;
           except
             if child[i].choiceindex>child[j].choiceindex then begin
                tmptreenode:=child[i];
                child[i]:=child[j];
                child[j]:=tmptreenode;
             end;
           end;

end;

function TMyTreeNode.addchild:TMyTreeNode;
begin
     if assigned(self) then begin
        inc(childcount);
        child[childcount]:=TMyTreeNode.Create;
        addchild:=child[childcount];
        child[childcount].parent:=self;
     end else begin
        addchild:=TMyTreeNode.Create;
     end;
end;
end.
