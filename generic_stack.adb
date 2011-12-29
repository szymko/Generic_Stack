with Unchecked_Deallocation, Ada.Containers.Generic_Array_Sort;

package body Generic_Stack is

  procedure Free_Stack is new Unchecked_Deallocation(Stack_Array, Stack_Array_Access);

  procedure Sort_Content_Array is new Ada.Containers.Generic_Array_Sort
     (Index_Type   => Integer,
      Element_Type => Item,
      Array_Type   => Content_Array);

  procedure Initialize(S : in out Stack) is
  begin
    S.Item_Array:= new Stack_array(0..Step);
    S.Head:=0;
    S.Tail:=0;
    S.Length:=0;
   -- S.Current:=0;
    S.Capacity:=Step;
    S.Last.Recent_Place:=-2;
    S.Last.Recent_Cell:=0;
  end Initialize;

  procedure Push_Front(S : in out Stack; I : in Item) is
    Temporary:Integer;
  begin
    if S.Item_Array = null then
      raise Constraint_Error;
    end if;
    if S.Length = S.Capacity then
      Adjust(S);
    end if;
    if S.Length = 0 then
      S.Length:=1;
      S.Head:=0;
      S.Tail:=0;
      S.Item_Array(0).Content:=I;
      S.Item_Array(0).Previous:=-1;
      --previous in list, not in array, -1 means it
      --should be moved to the front of an array if one was to add items
      --before tail
      S.Item_Array(0).Next:=1;
      --last member's next is a 'pointer' to the next item in list
    else
    --length higher than 0
    Temporary:=S.Item_Array(S.Head).Next;
    S.Length:=S.Length+1;
    S.Item_Array(Temporary).Content:=I;
    S.Item_Array(Temporary).Previous:=S.Head;
    S.Item_Array(Temporary).Next:=Temporary+1;
    S.Head:=Temporary;
    end if;
  end Push_Front;

  procedure Push_Bottom(S : in out Stack; I : in Item) is
    Temporary : Integer;
  begin
    if S.Item_Array = null then
      raise Constraint_Error;
    end if;
    if S.Length=S.Capacity then
      Adjust(S);
    end if;
    if S.Length = 0 then
      S.Length:=1;
      S.Head:=0;
      S.Tail:=0;
      S.Item_Array(0).Content:=I;
      S.Item_Array(0).Previous:=-1;
      --as in function above
      S.Item_Array(0).Next:=1;
      --last member's next is a 'pointer' to the next item in list
    else
    S.Length:=S.Length+1;
    S.Item_Array(S.Tail).Previous:=S.Item_Array(S.Head).Next;
    Temporary:=S.Item_Array(S.Head).Next;
    S.Item_Array(Temporary).Content:=I;
    S.Item_Array(Temporary).Previous:=-1;
    S.Item_Array(Temporary).Next:=S.Tail;
    S.Tail:=Temporary;
    S.Item_Array(S.Head).Next:=S.Item_Array(S.Head).Next+1;
  end if;
  end Push_Bottom;

  --by X there is indicated absolute position in the array, where X should be put counting from tail.
  procedure Push_Anywhere(S : in out Stack; I : in Item; Index : in Integer) is
    Temporary:Integer:=-1;
    Temporary_Previous:Integer;
  begin
     if Index = S.Last.Recent_Place then
        Temporary:=S.Last.Recent_Cell;
     elsif Index = S.Last.Recent_Place - 1 then
        Temporary:=S.Item_Array(S.Last.Recent_Cell).Previous;
        S.Last.Recent_Place:=Index;
        S.Last.Recent_Cell:=Temporary;
     elsif Index = S.Last.Recent_Place + 1 then
        Temporary:=S.Item_Array(S.Last.Recent_Cell).Previous;
        S.Last.Recent_Place:=Index;
        S.Last.Recent_Cell:=Temporary;
     end if;
    if S.Item_Array = null then
      raise Constraint_Error;
    elsif Index > S.Length or Index < 0 then
      raise Constraint_Error;
    elsif Index = 1 or Index = 0 then
      Push_Front(S, I);
    elsif Index = S.Length then
      Push_Bottom(S, I);
    else
      if S.Length = S.Capacity then
        Adjust(S);
      end if;
      S.Length:=S.Length+1;

      if Temporary = -1 then
        Temporary:=S.Head;
        for i in 2..Index-1 loop
          Temporary:=S.Item_Array(Temporary).Previous;
        end loop;
        S.Last.Recent_Place:=Index;
        S.Last.Recent_Cell:=Temporary;
      end if;

      --making temporary copy of the information of previous
      --place, which was before temporary
      Temporary_Previous:=S.Item_Array(Temporary).Previous;

      --putting content of item to the end of the table
      S.Item_Array(S.Item_Array(S.Head).Next).Content:=I;
      --making cell at the end point at the one before
      S.Item_Array(S.Item_Array(S.Head).Next).Previous:=Temporary_Previous;
      --making the chosen cell point at the one ahead
      S.Item_Array(S.Item_Array(S.Head).Next).Next:=Temporary;

      --making previous cell point at the chosen one
      S.Item_Array(Temporary_Previous).Next:=S.Item_Array(S.Head).Next;
      --making temporary point at the new previous one
      S.Item_Array(Temporary).Previous:=S.Item_Array(S.Head).Next;
      --incrementing next

      S.Item_Array(S.Head).Next:=S.Item_Array(S.Head).Next + 1; --adjusting length of a list by placing next 'pointer' one cell to the right
    end if;
  end Push_Anywhere;

  procedure Pop_Front(S : in out Stack; I : out Item) is
  begin
    if S.Length < 1 then
      raise Constraint_Error;
    end if;
    S.Length:=S.Length-1;
    I:=S.Item_Array(S.Head).Content;
    S.Head:=S.Item_Array(S.Head).Previous;
  end Pop_Front;

  procedure Pop_Bottom(S : in out Stack; I : out Item) is
  begin
    if S.Length < 1 then
      raise Constraint_Error;
    end if;
    S.Length:=S.Length-1;
    I:=S.Item_Array(S.Tail).Content;
    S.Tail:=S.Item_Array(S.Tail).Next;
  end Pop_Bottom;

  procedure Pop_Anywhere(S : in out Stack; I : out Item; Index : in Integer) is
    Temporary : Integer;
  begin
    if S.Item_Array = null then
      raise Constraint_Error;
    elsif Index > S.Length or Index < 0 or Index = 0 then
      raise Constraint_Error;
    elsif Index = 1 then
      Pop_Front(S, I);
    elsif Index = S.Length then
      Pop_Bottom(S,I);
    else
      S.Length:=S.Length-1;
      Temporary:=S.Head;
      for i in 2..Index loop
        Temporary:=S.Item_Array(Temporary).Previous;
      end loop;
      Delete_Cell(S, Temporary);
    end if;
  end Pop_Anywhere;

  procedure Remove_Each(S : in out Stack; I : in Item) is
    Temporary:Integer:=S.Head;
    Iterator:Integer:=1;
    Counter:Integer:=0;
  begin
    if S.Item_Array = null then
      raise Constraint_Error;
    end if;
    while not (Iterator > S.Length) loop
      if(S.Item_Array(Temporary).Content = I)then
        if(S.Item_Array(Temporary).Previous = -1) then
          S.Tail:=S.Item_Array(S.Tail).Next;
          Temporary:=S.Tail;
          Counter:=Counter+1;
        elsif Temporary = S.Head then
          S.Head := S.Item_Array(S.Head).Previous;
          Temporary:=S.Head;
          Counter:=Counter+1;
        else
          Delete_Cell(S, Temporary);
          Counter:=Counter+1;
        end if;
      else
        Temporary:=S.Item_Array(Temporary).Previous;
      end if;
      iterator:=iterator+1;
    end loop;
    S.Length:=S.Length-Counter;
  end Remove_Each;

  procedure Remove_First(S : in out Stack; I : in Item) is
    Temporary:Integer:=S.Head;
    Iterator:Integer:=1;
    Counter:Integer:=0;
  begin
    if S.Item_Array = null then
      raise Constraint_Error;
    end if;
    while not (Iterator > S.Length) and Counter = 0 loop
      if(S.Item_Array(Temporary).Content = I) then
        if(S.Item_Array(Temporary).Previous = -1) then
          S.Tail:=S.Item_Array(S.Tail).Next;
          Counter:=Counter+1;
        elsif Temporary = S.Head then
          S.Head := S.Item_Array(S.Head).Previous;
          Counter:=Counter+1;
        else
          Delete_Cell(S, Temporary);
          Counter:=Counter+1;
        end if;
      else
        Temporary:=S.Item_Array(Temporary).Previous;
      end if;
      Iterator:=Iterator+1;
    end loop;
    S.Length:=S.Length-Counter;
  end Remove_First;

  procedure Remove_All(S : in out Stack) is
  begin
    if S.Item_Array = null then
      raise Constraint_Error;
    end if;
    S.Length:=0;
    S.Head:=0;
    S.Tail:=0;
    S.Last.Recent_Place:=-2;
    S.Last.Recent_Cell:=0;
  end Remove_All;

  procedure RM_Front(S : in out Stack) is
  begin
    if S.Length < 1 then
      raise Constraint_Error;
    end if;
    S.Length:=S.Length-1;
    S.Head:=S.Item_Array(S.Head).Previous;
  end RM_Front;

  procedure RM_Bottom(S : in out Stack) is
  begin
    if S.Length < 1 then
      raise Constraint_Error;
    end if;
    S.Length:=S.Length-1;
    S.Tail:=S.Item_Array(S.Tail).Next;
  end RM_Bottom;

  procedure RM_Anywhere(S : in out Stack; Index : in Integer) is
    Temporary : Integer;
  begin
    if S.Item_Array = null then
      raise Constraint_Error;
    elsif Index > S.Length or Index < 0 or Index = 0 then
      raise Constraint_Error;
    elsif Index = 1 then
      RM_Bottom(S);
    elsif Index = S.Length then
      RM_Front(S);
    else
      S.Length:=S.Length-1;
      Temporary:=S.Tail;
      for i in 2..Index loop
        Temporary:=S.Item_Array(Temporary).Next;
      end loop;
      Delete_Cell(S,Temporary);
    end if;
  end RM_Anywhere;

  function Top(S : in Stack) return Item is
  begin
    return S.Item_Array(S.Head).Content;
  end Top;

  function Bottom(S : in Stack) return Item is
  begin
    return S.Item_Array(S.Tail).Content;
  end Bottom;

  function Anywhere(S : in Stack; Index : in Integer) return Item is
    Temporary:Integer:=S.Head;
  begin
    if Index > S.Length or Index < 1 then
      raise Constraint_Error;
    end if;

    for i in 2..Index loop
      Temporary:=S.Item_Array(Temporary).Previous;
    end loop;
    return S.Item_Array(Temporary).Content;
  end Anywhere;

  function How_many(S : in Stack) return Natural is
  begin
    return S.Length;
  end How_many;

  procedure Adjust(S : in out Stack) is
    temp:Stack_Array(1..S.Capacity):=S.Item_Array.all;
  begin
    Free_Stack(S.Item_Array);
    S.Item_Array:=new Stack_Array(1..S.Capacity+Step);
    S.Item_Array(1..S.Capacity):=temp(1..S.Capacity);
    S.Capacity:=S.Capacity+Step;
  end Adjust;

  procedure Finalize (S : in out Stack) is
  begin
    Free_Stack(S.Item_Array);
  end Finalize;

  procedure Sort(S : in out Stack) is
    temp_array:Content_Array(1..S.Length);
    temp_pr:Integer:=S.Head;
  begin
    if S.Item_Array = null then
      raise Constraint_Error;
    end if;
    for i in temp_array'Range loop
      temp_array(i):=S.Item_Array(temp_pr).Content;
      temp_pr:=S.Item_Array(temp_pr).Previous;
    end loop;
    Sort_Content_Array(temp_array);
    for i in temp_array'Range loop
      S.Item_Array(i).Content:=temp_array(i);
      S.Item_Array(i).Previous:=i-1;
      S.Item_Array(i).Next:=i+1;
    end loop;
    S.Head:=S.Length;
    S.Tail:=0;
    S.Last.Recent_Place:=-2;
  end Sort;

  procedure Delete_Cell(S : in out Stack; Temporary :in out Integer) is
    Temp_previous:Integer;
  begin
         --passing 'pointer' to cell ahead to temporary variable
          Temp_Previous:=S.Item_Array(Temporary).Previous;
          --making a cell behind removed point at the cell in front of removed
          S.Item_Array(S.Item_Array(Temporary).Previous).Next:=S.Item_Array(Temporary).Next;
          --completing the linkage
          S.Item_Array(S.Item_Array(Temporary).Next).Previous:=S.Item_Array(Temporary).Previous;
          --Moving the top of the stack to the empty place
          --1.making the linkages between the top and the rest.
          --a)linking stack with the top:
          S.Item_Array(S.Item_Array(S.Head).Previous).Next:=Temporary;
          --b)and the top with the list:
          S.Item_Array(Temporary).Previous:=S.Item_Array(S.Head).Previous;
          --c)link to the next top cell
          S.Item_Array(Temporary).Next:=S.Head;
          --2.finally switching the contents
          S.Item_Array(Temporary).Content:=S.Item_Array(S.Head).Content;
          --3.moving the pointer to the head
          S.Head:=Temporary;
          --switching the temporary var to the next element of stack
          Temporary:=Temp_Previous;
  end Delete_Cell;

  end Generic_Stack;

