[Setup]
Bits=32
AppName=EasyBBS Builder
AppVerName=EZBBS 49
AppCopyright=DreamStair
DefaultDirName={pf}\EZBBS
DefaultGroupName=EasyBBS Builder

[Files]
Source: "EZBBS.EXE"; DestDir: "{app}"
Source: "USEREDITOR.EXE"; DestDir: "{app}"
Source: "MENUEDITOR.EXE"; DestDir: "{app}"

[Icons]
Name: "{group}\EZBBS"; Filename: "{app}\EZBBS.EXE"
Name: "{group}\MENUEDITOR"; Filename: "{app}\MENUEDITOR.EXE"
Name: "{group}\USEREDITOR"; Filename: "{app}\USEREDITOR.EXE"

