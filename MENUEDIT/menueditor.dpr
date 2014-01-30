program menueditor;

uses
  Forms,
  menuedit in 'menuedit.pas' {Form1},
  menuedit_window_2 in 'menuedit_window_2.pas' {Form2},
  menuedit_about in 'menuedit_about.pas' {AboutBox},
  menuedit_idinput in 'menuedit_idinput.pas' {Input};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TInput, Input);
  Application.Run;
end.
