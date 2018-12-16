defmodule Number do
  @moduledoc """

    Function findAndPrintPerfectSquareSum/1
    Finds the window of numbers where, sum of squares = perfect square
      #Example for finding sq(3) + sq(4) = sq(5)
         number=4, k=2
         number - k =2
         findAndPrintPerfectSquareSum(4) - findAndPrintPerfectSquareSum(2) = 30 - 5 = 25 (which in simpler terms is sq(3) + sq(4))
         sqrt(25) = 5
         number - k + 1 = 3
         {:result, 3}

    Function squareSum/1
    Finds the sum of squares till the ith natural number.
      #Example
      squareSum(3) = 14 (1 + 4 + 9)
  """

  def startServer(n, k) do
    parent = self()
    server_id = spawn_link(fn -> loop(n + k, k, k, k + step(n), parent) end)
    updateGlobalReference(server_id, parent)
    createNode("server")
    printNumber("127.0.0.1")
    waitServer()
  end

  defp waitServer() do
    receive do
      :done ->
        :timer.sleep(100)

        if(length(Node.list()) > 0) do
          waitServer()
        else
          IO.puts("Completed everything")
        end
    end
  end

  defp createNode(name) do
    {:ok, iflist} = :inet.getif()
    createServerNodeFromIP(Enum.reverse(iflist), name)
  end

  defp updateGlobalReference(server_id, parent) do
    :global.register_name(:server, server_id)
    :global.register_name(:main, parent)
    :global.sync()
  end

  defp createServerNodeFromIP([head | tail], name) do
    unless Node.alive?() do
      try do
        ipAddr = getIPString(head)

        if ipAddr === "127.0.0.1",
          do: retry(tail, name),
          else: startNodeAndSetCookie(name <> "@" <> ipAddr)
      rescue
        _ -> retry(tail, name)
      end
    end
  end

  defp getIPString(networkDetails) do
    {ip_tuple, _, _} = networkDetails
    to_string(:inet_parse.ntoa(ip_tuple))
  end

  defp retry(remainingIPs, name) do
    if length(remainingIPs) > 0,
      do: createServerNodeFromIP(remainingIPs, name),
      else: IO.puts("Unable to create Node.")
  end

  defp startNodeAndSetCookie(ipAddrString) do
    nodeName = String.to_atom(ipAddrString)
    Node.start(nodeName)
    Node.set_cookie(nodeName, :sum)
  end

  defp loop(n, k, start, last, parent) do
    newlast = min(n, last)

    if n > start do
      receive do
        {:get, caller} -> send(caller, {:answer, start, newlast, k})
        {:result, result} -> IO.puts(result)
      end

      loop(n, k, newlast + 1, newlast + step(n), parent)
    else
      receive do
        {:get, caller} -> send(caller, {:answer, 0, 0, k})
        {:result, result} -> IO.puts(result)
      end

      loop(n, k, start, last, parent)
    end
  end

  def printNumber(serverAddr) do
    createNode("worker" <> randomNum())
    serverId = connectToServerAndGetServerId(serverAddr)
    numberOfThreads = 2 * System.schedulers_online()

    parent = self()

    for _ <- 1..numberOfThreads do
      spawn_link(fn -> getAndProcessNumber(serverId, parent) end)
    end

    wait(numberOfThreads)
  end

  defp connectToServerAndGetServerId(serverAddr) do
    Node.connect(String.to_atom(serverAddr))
    :global.sync()
    :global.whereis_name(:server)
  end

  defp wait(0) do
    IO.puts("completed work")
    send(:global.whereis_name(:main), :done)
    Node.stop()
  end

  defp wait(numberOfThreads) do
    receive do
      :done -> wait(numberOfThreads - 1)
    end
  end

  defp getAndProcessNumber(sid, parent) do
    send(sid, {:get, self()})

    receive do
      {:answer, 0, 0, _} ->
        send(parent, :done)

      {:answer, start, last, k} ->
        findPerfectSquareInSumRange(start, last, k, sid)
        getAndProcessNumber(sid, parent)
    end
  end

  defp findPerfectSquareInSumRange(start, last, k, sid) do
    Enum.map(start..last, fn x -> findAndPrintPerfectSquareSum(x, k, sid) end)
  end

  defp findAndPrintPerfectSquareSum(number, k, sid) do
    sum = squareSum(number) - squareSum(number - k)
    sqrt = sum |> :math.sqrt() |> :math.ceil()

    if sqrt * sqrt == sum do
      send(sid, {:result, number - k + 1})
    end
  end

  defp squareSum(number) do
    div(number * (number + 1) * (2 * number + 1), 6)
  end

  defp step(n) do
    max(1, div(n, 8 * 8))
  end

  defp randomNum() do
    :rand.uniform(50) |> to_string
  end
end
