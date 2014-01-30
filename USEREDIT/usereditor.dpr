program usereditor;

uses
  Forms,
  Unit1 in 'Unit1.pas' {UserEdit},
  Unit2 in 'Unit2.pas' {DataEdit};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TUserEdit, UserEdit);
  Application.CreateForm(TDataEdit, DataEdit);
  Application.Run;
end.
