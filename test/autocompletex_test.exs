defmodule AutocompletexTest do
  use ExUnit.Case
  doctest Autocompletex

  setup do
    {:ok, conn} = Redix.start_link
    {:ok, worker1} = Autocompletex.Worker.start_link(conn)
    {:ok, worker: worker1, redis: conn} 
  end

  test "redis connection", state do
    %{redis: conn} = state
    Autocompletex.start()
    Redix.command(conn, ~w(SET test ok) )
    case Redix.command(conn, ~w(GET test) ) do 
      {:ok, word} ->
        assert word == "ok"
      {:error, err} -> 
        IO.puts err
        assert false
    end
  end

  test "ping pong for redis", state do
    %{worker: worker} = state

    assert {:ok, "PONG"} = Autocompletex.Worker.ping(worker)
  end

  test "generate prefix" do
  assert ["test"] |> Autocompletex.Helper.prefixes == ["t", "te", "tes", "test*"]
  end

  test "generate prefixes from a list of string, flattened" do
    assert Autocompletex.Helper.prefixes(~w(test example)) == 
      ["t", "te", "tes", "test*", "e", "ex", "exa", "exam", "examp", "exampl", "example*"]
  end

  test "insert a prefix string", state do
    %{worker: worker, redis: conn} = state

    assert :ok == Autocompletex.Worker.insert(worker, ~w(test example))

    prefixes = Autocompletex.Helper.prefixes(~w(test example))

    prefixes
      |> Enum.map(
        fn prefix -> 
          case Redix.command(conn, ~w(ZRANK ZSET) ++ [prefix]) do
            {:ok, w} -> assert w < prefixes |> length
            {:error, err} -> assert false
          end
        end)
  end

end
