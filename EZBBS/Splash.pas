unit Splash;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TFSplash = class(TForm)
    Image1: TImage;
    Progress: TLabel;
    Bevel1: TBevel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FSplash: TFSplash;

implementation

uses MainUnit;

{$R *.DFM}

procedure TFSplash.FormCreate(Sender: TObject);
begin
//     application.getsyste
     image1.height:=clientHeight;
     image1.width:=clientWidth;
end;


end.
