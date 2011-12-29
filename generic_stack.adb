with Unchecked_Deallocation;

package body Generic_Stack is

  procedure Free_Stack is new Unchecked_Deallocation(Stack_Array, Stack_Array_Access);

  procedure Initialize(S : in out Stack) is
  begin
    S.Item_Array:= new Stack_array(0..Step);
    S.Head:=0;
    S.Tail:=0;
    S.Length:=0;
   -- S.Current:=0;
    S.Capacity:=Step;
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
    end if;
    --length higher than 0
    Temporary:=S.Item_Array(S.Head).Next;
    S.Length:=S.Length+1;
    S.Item_Array(Temporary).Content:=I;
    S.Item_Array(Temporary).Previous:=S.Head;
    S.Item_Array(Temporary).Next:=Temporary+1;
    S.Head:=Temporary;
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
    end if;
    S.Item_Array(S.Tail).Previous:=S.Item_Array(S.Head).Next;
    Temporary:=S.Item_Array(S.Head).Next;
    S.Item_Array(S.Head).Next:=S.Item_Array(S.Head).Next+1;
    S.Length:=S.Length+1;
    S.Item_Array(Temporary).Content:=I;
    S.Item_Array(Temporary).Previous:=-1;
    S.Item_Array(Temporary).Next:=S.Tail;
    S.Tail:=Temporary;
  end Push_Bottom;

  --by X there is indicated absolute position in the array, where X should be put counting from tail.
  procedure Push_Anywhere(S : in out Stack; I : in Item; Index : in Integer) is
    Temporary:Integer;
  begin
    if S.Item_Array = null then
      raise Constraint_Error;
    elsif Index > S.Length + 1 or Index < 0 then
      raise Constraint_Error;
    elsif Index = 0 then
      Push_Bottom(S, I);
    elsif Index = S.Length + 1 then
      Push_Front(S, I);
    else
      if S.Length = S.Capacity then
        Adjust(S);
      end if;
      S.Length:=S.Length+1;
      Temporary:=S.Tail;
      for i in 2..Index loop
        Temporary:=S.Item_Array(Temporary).Next;
      end loop;
      S.Item_Array(S.Item_array(S.Head).Next).Content:=I;
      --rather awfull looking insertion of a new content to a new cell
      S.Item_Array(S.Item_array(S.Head).Next).Previous:=S.Item_array(Temporary).Previous;
      S.Item_Array(S.item_array(S.Head).Next).Next:=Temporary;
      --for the "moved" piece the only thing that changes is previous 'pointer'
      S.Item_Array(Temporary).Previous:=S.Item_array(S.Head).Next;
      if Index = 1 then
        S.Tail:=S.Item_array(S.Head).Next;
      end if;
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
      Pop_Bottom(S, I);
    elsif Index = S.Length then
      Pop_Front(S,I);
    else
      S.Length:=S.Length-1;
      Temporary:=S.Tail;
      for i in 2..Index loop
        Temporary:=S.Item_Array(Temporary).Next;
      end loop;
      I:=S.Item_Array(Temporary).Content;
      --inserting head in the place of the old cell while keeping list
      --in order
      S.Item_Array(S.Item_Array(Temporary).Previous).Next:=S.Item_Array(Temporary).Next;
      S.Item_Array(S.Item_Array(S.Head).Previous).Next:=Temporary;
      S.Item_Array(Temporary):=S.Item_Array(S.Head);
      S.Item_Array(Temporary).Next:=S.Head;
      S.Head:=Temporary;
    end if;
  end Pop_Anywhere;

  procedure Remove_Each(S : in out Stack; I : in Item) is
    Temporary:Integer:=S.Tail;
    Iterator:Integer:=1;
    Counter:Integer:=0;
  begin
    if S.Item_Array = null then
      raise Constraint_Error;
    end if;
    while Iterator < S.Length loop
      if(S.Item_Array(Temporary).Content = I) then
        S.Item_Array(S.Item_Array(Temporary).Previous).Next:=S.Item_Array(Temporary).Next;
        S.Item_Array(S.Item_Array(S.Head).Previous).Next:=Temporary;
        S.Item_Array(Temporary):=S.Item_Array(S.Head);
        S.Item_Array(Temporary).Next:=S.Head;
        S.Head:=Temporary;
        Iterator:=Iterator+1;
        Counter:=Counter+1;
      else
        Temporary:=S.Item_Array(Temporary).Next;
      end if;
    end loop;
    S.Length:=S.Length-Counter;
  end Remove_Each;

  procedure Remove_First(S : in out Stack; I : in Item) is
    Temporary:Integer:=S.Tail;
    Iterator:Integer:=1;
    Counter:Integer:=0;
  begin
    if S.Item_Array = null then
      raise Constraint_Error;
    end if;
    while Iterator < S.Length or Counter = 0 loop
      if(S.Item_Array(Temporary).Content = I) then
        S.Item_Array(S.Item_Array(Temporary).Previous).Next:=S.Item_Array(Temporary).Next;
        S.Item_Array(S.Item_Array(S.Head).Previous).Next:=Temporary;
        S.Item_Array(Temporary):=S.Item_Array(S.Head);
        S.Item_Array(Temporary).Next:=S.Head;
        S.Head:=Temporary;
        Counter:=Counter+1;
      else
        Temporary:=S.Item_Array(Temporary).Next;
      end if;
    end loop;
    S.Length:=S.Length-1;
  end Remove_First;

  procedure Remove_All(S : in out Stack) is
  begin
    if S.Item_Array = null then
      raise Constraint_Error;
    end if;
    S.Length:=0;
    S.Head:=0;
    S.Tail:=0;
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
      --inserting head in the place of the old cell while keeping list
      --in order
      S.Item_Array(S.Item_Array(Temporary).Previous).Next:=S.Item_Array(Temporary).Next;
      S.Item_Array(S.Item_Array(S.Head).Previous).Next:=Temporary;
      S.Item_Array(Temporary):=S.Item_Array(S.Head);
      S.Item_Array(Temporary).Next:=S.Head;
      S.Head:=Temporary;
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
    Temporary:Integer:=-1;
  begin
    for i in 1..Index loop
      Temporary:=S.Item_Array(Temporary).Next;
    end loop;
    if Temporary > -1 then
      return S.Item_Array(Temporary).Content;
    else
      raise Constraint_Error;
    end if;
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

  end Generic_Stack;
