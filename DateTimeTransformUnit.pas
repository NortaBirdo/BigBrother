{Unit MainForm;
Version: 1.0;
Date of last editing: 16/05/13 19:46
Bond: SysUtils

developer: Sokolovskiy Nikolay
e-mail: sokolovskynik@gmail.com

description: Unit including functions for transformations DateTime}

unit DateTimeTransformUnit;

interface

uses SysUtils;
 function IntToDateTimeStr(Number :integer) :string;

implementation

function IntToDateTimeStr(Number :integer) :string;
var
i :integer;
begin
  i := Number div 3600;
  if i < 10 then result :=  '0' + IntToStr (i) + ':'
            else result := IntToStr (i) + ':';
  i := (Number mod 3600)  div 60;
  if i < 10 then result :=  result + '0' + IntToStr (i) + ':'
            else result := result + IntToStr (i) + ':';

  i := (Number mod 3600)  mod 60;
  if i < 10 then result :=  result + '0' + IntToStr (i)
            else result := result + IntToStr (i);

end;

end.
