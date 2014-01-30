unit menuedit_about;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    Copyright: TLabel;
    OKButton: TButton;
    Version: TLabel;
    Product: TLabel;
    Image1: TImage;
    procedure CopyrightClick(Sender: TObject);
    procedure CopyrightMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation
uses shellapi;
{$R *.DFM}

procedure TAboutBox.CopyrightClick(Sender: TObject);
begin
     shellexecute(handle,'open','mailto:innoboy@nownuri.net',nil,nil,sw_shownormal);
end;

procedure TAboutBox.CopyrightMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
     Copyright.font.color:=clRed;
end;

procedure TAboutBox.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
     Copyright.font.color:=clBlue;
end;

procedure TAboutBox.Image1Click(Sender: TObject);
begin
     shellexecute(handle,'open','http://para.co.kr/~fromcats',nil,nil,sw_shownormal);
end;

end.

