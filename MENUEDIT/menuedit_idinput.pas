unit menuedit_idinput;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TInput = class(TForm)
    OK: TButton;
    Edit1: TEdit;
    procedure FormShow(Sender: TObject);
    procedure OKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Input: TInput;

implementation

uses menuedit_window_2;

{$R *.DFM}

procedure TInput.FormShow(Sender: TObject);
begin
     Edit1.Clear;
end;

procedure TInput.OKClick(Sender: TObject);
begin
     form2.listbox1.items.add(edit1.text);
     close;
end;

end.
