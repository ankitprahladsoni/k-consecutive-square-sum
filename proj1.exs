defmodule Project1 do
  list = System.argv()
  IO.inspect list
  if String.contains?(hd(list),".") do
    Number.printNumber(hd(list))
  else
    [n,k] = list
   Number.startServer(String.to_integer(n),String.to_integer(k))
  end
end
