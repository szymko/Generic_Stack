--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--                          Generic_Stack                                     --
--
-- An attempt of creating time efficient stack, which combines the features   --
-- both an array(faster, rare allocation and reallocation of memory) with the --
-- ones of a double-linked list - mainly keeping data in order. Also there is --
-- used an idea of efficient array splicing, presented at                     --
-- http://cjcat.blogspot.com/2010/05/stardust-v11-with-fast-array-splicing_21.--
-- html.                                                                      --
--                                                                            --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--                      sobanski.s@gmail.com                                  --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

with Ada.Finalization; use Ada.Finalization;
generic
  type Item is private;
  with function "<" (Left,Right : Item) return Boolean is <>;
package Generic_Stack is

  type Cell is private;
  type Cash is private;
  type Content_Array is array(Integer range<>) of Item;
  type Stack_Array is array(Integer range<>) of Cell;
  type Stack_Array_Access is access all Stack_Array;
  type Stack is new Controlled with private;

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
  procedure Sort(S : in out Stack);
  procedure Initialize(S : in out Stack);

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
  procedure Delete_Cell(S : in out Stack; Temporary :in out Integer);


end Generic_Stack;



