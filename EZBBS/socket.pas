unit Socket;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFrmConnection = class(TForm)
    Tot: TLabel;
    StaticText1: TStaticText;
    HideBtn: TButton;
    procedure HideBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    UserNums:integer;
    procedure ChangeTotalUser(UserNum:integer);
    function GetTotalUser:integer;
  public
    property TotalUser:integer read GetTotalUser write ChangeTotalUser;

    { Public declarations }
    procedure WndProc(var Message:TMessage); override;
  end;

var
  FrmConnection: TFrmConnection;

procedure Socket_Init;
procedure closesock;

implementation

uses Winsock,MainUnit,Client, httpcont,declare,log;

var
    Socket_ID:integer;
    WSData:TWSadata;
    MyAddr:TSockAddr;

{$R *.DFM}
procedure TFrmConnection.ChangeTotalUser(UserNum:integer);
begin
     UserNums:=UserNum;
     Self.Tot.Caption:=Inttostr(UserNums);
     mainform.StatusBar1.Panels[0].text:='ÃÑ Á¢¼ÓÀÚ : '+inttostr(usernum);
end;
function TFrmConnection.GetTotalUser:integer;
begin
     gettotaluser:=UserNums;
end;

procedure TFrmConnection.WndProc(var Message:TMessage);
var TempClient: TSockAddr;
    TmpSize:integer;
    Tmpsockid:integer;
begin
     case Message.Msg of
          wm_user:
            case wsagetselectevent(Message.LParam) of
                 fD_read:begin
                       executeuser(message.WParam);
                       exit;
                 end;
                 fd_write:exit;
                 fd_accept: begin
                           tmpsize:=sizeof(tempclient);
                           tmpsockid:=winsock.accept(Socket_ID,@TempClient,@tmpsize);
                           Winsock.WSAAsyncSelect(TmpSockID,FrmConnection.Handle, WM_User, FD_Read or FD_close);
                           adduser(TmpSockid,TempClient.sin_addr.S_addr);
                         exit;
                 end;
                 fd_close: begin
                           deleteuser(message.wparam);
                          logwrite('connction closed from '+inttostr(message.WParam));
                         exit;
                 end;
            end;
     end;

     inherited;
     //
end;

procedure closesock;
begin
     closesocket(socket_id);

end;

procedure TFrmConnection.HideBtnClick(Sender: TObject);
begin
     hide;
end;


procedure Socket_Init;
begin
     frmconnection.changetotaluser(0);
     PLAYVOICE('SOCKINIT');
     Socket_ID:=winsock.socket(pf_inet,sock_stream,ipproto_tcp);
     if Socket_ID<0 then begin
        PLAYVOICE('ERROR');
        Raise Exception.Create('Failed: Getting Socket ID');
     end;
     MyAddr.sin_family:=af_inet;
     MyAddr.Sin_Port:=htons(telnetport);
     MyAddr.sin_addr.s_addr:=inaddr_any;
     if Bind(Socket_ID,MyAddr,sizeof(MyAddr))<0 then BEGIN
        PLAYVOICE('SOCKINIT');
        Raise Exception.Create('Failed: Binding');
     END;
     if Listen(Socket_ID, 10)<0 then BEGIN
        PLAYVOICE('SOCKINIT');
        Raise Exception.Create('Failed: listening');
     END;
     Winsock.WSAAsyncSelect(Socket_ID,FrmConnection.Handle, WM_User, FD_Accept);
end;

procedure TFrmConnection.FormCreate(Sender: TObject);
begin
     if WSAStartup($0101,WSData)<0 then
        Raise Exception.Create('Failed: Winsock Startup');
end;

end.
