with Ada.Finalization; use Ada.Finalization;
generic
  type Item is private;
  --swith function "<" (Left,Right : Item) return Boolean;
package Generic_Stack is

  type Cell is private;
  type Cash is private;
  type Stack_Array is array(Integer range<>) of Cell;
  type Stack_Array_Access is access all Stack_Array;
  type Stack is new Controlled with private;
  --function "="(Left : in Stack; Right : in Stack) return Boolean;

  Step:constant:=1_000_000;

  procedure Push_Front(S : in out Stack; I : in Item);
  procedure Push_Bottom(S : in out Stack; I : in Item);
  procedure Push_Anywhere(S : in out Stack; I : in Item; Index : in Integer);
  procedure Pop_Front(S : in out Stack; I : out Item);
  procedure Pop_Bottom(S : in out Stack; I : out Item);
  procedure Pop_Anywhere(S : in out Stack; I : out Item; Index : in Integer);
  procedure Remove_Each(S : in out Stack; I : in Item);
  procedure Remove_First(S : in out Stack; I : in Item);
  procedure Remove_All(S : in out Stack);
  procedure RM_Front(S : in out Stack);
  procedure RM_Bottom(S : in out Stack);
  procedure RM_Anywhere(S : in out Stack; Index : in Integer);
  --procedure Sort(S : in out Stack);
  procedure Initialize(S : in out Stack);

  --function Is_Empty(S : in Stack) return Boolean;
  function Top(S : in Stack) return Item;
  function Bottom(S : in Stack) return Item;
  function Anywhere(S : in Stack; Index : in Integer) return Item;
  function How_many(S : in Stack) return Natural;

private
  type Cell is
     record
       Content:Item;
       Previous:Integer;
       Next:Integer;
     end record;

  type Cash is
     record
       Recent_Place:Integer;
       Recent_Cell:Integer;
     end record;


  type Stack is new Controlled with record
    Item_Array:Stack_array_access:=null;
    Head:Natural;
    Tail:Integer;
    Length:Natural;
    Capacity:Natural;
    Last:Cash;
  end record;


  procedure Adjust(S : in out Stack);
  procedure Finalize(S : in out Stack);


end Generic_Stack;



