program EZBBS;

uses
  Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  Splash in 'Splash.pas' {FSplash},
  Socket in 'Socket.pas' {FrmConnection},
  Client in 'Client.pas',
  Utils in 'Utils.pas',
  httpcont in 'httpcont.pas' {HTTPFORM},
  sockset in 'sockset.pas' {SocketSetup},
  envior in 'envior.pas' {EnViorSet},
  about in 'about.pas' {AboutBox},
  Log in 'Log.pas' {LogForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'EasyBBS Builder';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TFSplash, FSplash);
  Application.CreateForm(TFrmConnection, FrmConnection);
  Application.CreateForm(THTTPFORM, HTTPFORM);
  Application.CreateForm(TLogForm, LogForm);
  FSplash.show;
  mainform.Show;
  FSplash.Destroy;
  Application.Run;
end.
