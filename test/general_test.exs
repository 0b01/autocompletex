defmodule AutocompletexTest do
  use ExUnit.Case

  setup do
    {:ok, conn} = Redix.start_link
    {:ok, worker1} = Autocompletex.Lexicographic.start_link(conn, 'testdb2', :ac)
    {:ok, worker: worker1, redis: conn}
  end

  test "redis connection", state do
    %{redis: conn} = state
    Autocompletex.start([],[])
    Redix.command(conn, ~w(SET test ok) )
    case Redix.command(conn, ~w(GET test) ) do 
      {:ok, word} ->
        assert word == "ok"
      {:error, err} -> 
        IO.puts err
        assert false
    end

    {:ok, _} = Redix.command(conn, ~w(DEL test))
  end

  test "ping for redis", state do
    %{worker: worker} = state
    assert {:ok, "PONG"} = Autocompletex.Lexicographic.ping(worker)
  end

  test "generate prefix" do
    assert ["test"] |> Autocompletex.Helper.prefixes_lexicographic == ["t", "te", "tes", "test*"]
    assert ["test"] |> Autocompletex.Helper.prefixes_predictive == ["t", "te", "tes", "test"]
  end

  test "generate prefixes from a list of string, flattened" do
    assert Autocompletex.Helper.prefixes_lexicographic(~w(test example)) == 
      ["t", "te", "tes", "test*", "e", "ex", "exa", "exam", "examp", "exampl", "example*"]
    assert Autocompletex.Helper.prefixes_predictive(~w(test example)) == 
      ["t", "te", "tes", "test", "e", "ex", "exa", "exam", "examp", "exampl", "example"]
  end


end
