with Ada.Text_IO, Ada.Sequential_IO, Generic_Stack,  Ada.Calendar, Ada.Integer_Text_IO;
use Ada.Text_IO,  Ada.Calendar, Ada.Integer_Text_IO;
procedure list_tester is
  type Str_8 is new String(1..8);
  subtype My_Char is Character range ' '..'z';
  subtype My_Int is Integer range 1..10000000;
  package Int_IO is new Ada.Sequential_IO(My_Int); use Int_IO;
  package Fix_IO is new Ada.Text_IO.Fixed_IO(DAY_DURATION);use Fix_IO;
  package Str_8_IO is new Ada.Sequential_IO(Str_8); use Str_8_IO;
  DataIF:Int_IO.File_Type;
  DataSF:Str_8_IO.File_Type;
  S:Str_8;
  X:My_Int;
  package List_Int is new Generic_Stack(My_Int); use List_Int;
  package List_Str_8 is new Generic_Stack(Str_8); use List_Str_8;
  L1:List_Int.Stack;
  L2:List_Str_8.Stack;
  Size,Cnt: Integer;
  year,month,day : Integer;
  start,seconds  : Day_duration;
  time_and_date  : Time;
begin
  Int_IO.Open(DataIF,Int_IO.In_File,"Test_Data/liczby.dat");
  Size:= 1_000_000; --znamy z gory wielkosc pliku testowego
  Cnt:=0;

  Initialize(L1);
  Initialize(L2);

  time_and_date := Clock;
  Split(time_and_date, year, month, day, start);

  for i in 1 .. 1_000_000 loop
    Int_IO.Read(DataIF,X);
    if (Cnt>2*Size/3) then
	Push_Bottom(L1,X);
    elsif(Cnt>Size/3) then
      Push_Front(L1,X);
    else
    Push_Anywhere(L1,X, Cnt/3);
    end if;
    Cnt:= Cnt + 1;
  end loop;
  Int_IO.Close(DataIF);
  Put_Line("Czytanie L1 skonczone.");
  Sort(L1);

  for idx in 1..3000 loop

    RM_Bottom(L1);

    RM_Front(L1);

    RM_Anywhere(L1,idx);
    null;
  end loop;
  Remove_Each(L1,Top(L1));
  Remove_First(L1,Bottom(L1));
  Remove_Each(L1, Anywhere(L1,2));
  Put_Line("Usuwanie z L1 skonczone");
  Put("Liczba elementow w L1:");
  Put(How_many(L1));
  New_Line;
  for idx in 1..3000 loop

    Pop_Front(L1,X);

    Pop_Bottom(L1,X);

    Pop_Anywhere(L1,X,idx);
    null;
  end loop;

  Remove_All(L1);
  Finalize(L1);
  Put_Line("L1-gotowe");

  Cnt:=0;
  Str_8_IO.Open(DataSF,Str_8_IO.In_File,"Test_Data/napisy.dat");
  Size:= 100_000;
  for i in 1 .. 100_000 loop
    Str_8_IO.Read(DataSF,s);
    if (Cnt>2*Size/3) then
	Push_Bottom(L2,s);
    elsif(Cnt>Size/3) then
      Push_Front(L2,s);
    else
    Push_Anywhere(L2,s, Cnt/3);
    end if;
    Cnt:= Cnt + 1;
  end loop;
  Str_8_IO.Close(DataSF);
  Put_Line("Czytanie L2 skonczone.");
  Sort(L2);

  for idx in 1..2000 loop
    RM_Bottom(L2);
    RM_Front(L2);
    RM_Anywhere(L2, idx);
    null;
  end loop;
  Remove_Each(L2,Top(L2));
  Remove_First(L2,Bottom(L2));
  Remove_Each(L2, Anywhere(L2,2));
  Put_Line("Usuwanie z L2 skonczone");
  Put("Liczba elementow w L2:");
  Put(How_many(L2));
  New_Line;
  for idx in 1..2000 loop

    Pop_Front(L2,s);

    Pop_Bottom(L2,s);

    Pop_Anywhere(L2,s,idx);
    null;
  end loop;

  Remove_All(L2);
  Finalize(L2);
  Put_Line("L2-gotowe");
  time_and_date := Clock;
  Split(time_and_date, year, month, day, seconds);
  Put("Wykonanie zajelo ");
  Put(Seconds - Start, 8, 3, 0);
  Put(" sekund.");
end list_tester;
