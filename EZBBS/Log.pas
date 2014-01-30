unit Log;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TLogForm = class(TForm)
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LogForm: TLogForm;
  LogBox: TListBox;

procedure LogWrite(logstr:String);

implementation
uses declare;
{$R *.DFM}

procedure LogWrite(logstr:String);
var file1:textfile;
    datestr:string;
begin
  try
     LogBox.Items.Add(datetostr(date)+',' +timetostr(time)+' : '+logstr);
     datestr:=exedir+'log\'+datetostr(date)+'.log';
     assignfile(file1,datestr);
     if fileexists(datestr) then
        append(file1)
     else
        rewrite(file1);
     writeln(file1,datetostr(date)+',' +timetostr(time)+' : '+logstr);
     closefile(file1);
  except
  end;
//     LogBox.Items.SaveToFile();
end;

procedure TLogForm.FormResize(Sender: TObject);
begin
 LogBox.width:=clientwidth;
 LogBox.height:=clientheight;
end;

procedure TLogForm.FormCreate(Sender: TObject);
var i,j:integer;
    a,b:word;
    result:word;
    datestr:string;
begin
     LogBox:=TListBox.Create(self);
     LogBox.parent:=self;
     datestr:=exedir+'log\'+datetostr(date)+'.log';
     if fileexists(datestr) then
        LogBox.Items.LoadFromFile(datestr);
     LogBox.Show;

end;

procedure TLogForm.Timer1Timer(Sender: TObject);

begin
     repeat
     until false;
end;

end.
