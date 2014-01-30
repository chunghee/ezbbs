unit Utils;

interface
uses classes;
type
    TTLogwrite = class(tthread)

               private
//
               public
    end;

function iptostr(ipaddr:integer): string;
function midprt(src:string):string;
implementation
uses declare,sysutils;

function iptostr(ipaddr:integer): string;
var tmp:string;
    i:integer;
begin
     tmp:=inttostR((ipaddr and 255));
     for i:=1 to 3 do begin
       ipaddr:=ipaddr shr 8;
       tmp:=tmp+'.'+inttostR((ipaddr and 255));
     end;
     iptostr:=tmp;
//
end;
function midprt(src:string):string;
begin
     midprt:=chr(13)+esc+'['+inttostr(40-length(src) div 2)+'C'+ src+crlf;
end;
end.
