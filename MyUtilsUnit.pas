{Unit MyUtilsUnit;
Version: 1.0;
Date of last editing: 14/06/13 10:00
Bond:

developer: Sokolovskiy Nikolay
e-mail: sokolovskynik@gmail.com

description: Unit including different procedure}

unit MyUtilsUnit;

interface
 //Calculating payed time
 function CalcPayedTime(PayedSum, CostHour :real):integer;

implementation

//=====================================================
//How much time payed = PayedSum ($) / Cost Hour ($/h) = h
//How much second = h * 3600
function CalcPayedTime(PayedSum, CostHour :real):integer;
begin
  if CostHour = 0 then
   begin
     result := 0;
     exit;
   end;
 result := Round (PayedSum / CostHour * 3600) ;
end;

end.
