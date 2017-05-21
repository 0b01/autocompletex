defmodule AutocompletexInsertTest do
  use ExUnit.Case
  doctest Autocompletex
  import Autocompletex.Worker

  setup do
    {:ok, conn} = Redix.start_link
    {:ok, worker} = start_link(conn)
    {:ok, worker: worker, redis: conn} 
  end

  test "insert a prefix string", state do
    %{worker: worker, redis: conn} = state
    :ok = insert(worker, ["test", "example"])
    test_prefix_exists? conn, ["test", "example"]
    Redix.command(conn, ["FLUSHALL"])
  end

  test "autocomplete a prefix", state do
    %{worker: worker, redis: conn} = state
    :ok = insert(worker, ["test", "example"])
    assert complete(worker, "te") == {:ok, ["test"]}
    assert complete(worker, "ex") == {:ok, ["example"]}
    Redix.command(conn, ["FLUSHALL"])
  end

  test "increment a prefix", state do
    %{worker: worker, redis: conn} = state
    :ok = insert(worker, ["test", "example"])
    before = prefix_score conn, ["test"]

    :ok = incr(worker, "test")
    pscore_after = prefix_score conn, ["test"]
    assert Enum.zip(pscore_after, before)
      |> Enum.map(fn {b,a} -> String.to_integer(b) - String.to_integer(a) == 1 end) 
      |> Enum.all?
    Redix.command(conn, ["FLUSHALL"])
  end

  test "upsert a term - insert",state do
    %{worker: worker, redis: conn} = state
    :ok = upsert(worker, ["test", "example"])
    test_prefix_exists? conn, ["test", "example"]
    Redix.command(conn, ["FLUSHALL"])
  end

  test "upsert a term - incr", state do
    %{worker: worker, redis: conn} = state

    :ok = insert(worker, ["test", "example"])
    before = prefix_score conn, ["test"]

    :ok = upsert(worker, ["test", "example"])
    pscore_after = prefix_score conn, ["test"]
    assert Enum.zip(pscore_after, before)
      |> Enum.map(fn {b,a} -> String.to_integer(b) - String.to_integer(a) == 1 end) 
      |> Enum.all?

    :ok = upsert(worker, ["test", "example"])
    pscore_after_2 = prefix_score conn, ["example"]
    assert Enum.zip(pscore_after_2, pscore_after)
      |> Enum.all?(fn {b,a} -> String.to_integer(b) - String.to_integer(a) == 1 end) 
    assert pscore_after_2 |> Enum.all?(&(&1 == "2"))
    Redix.command(conn, ["FLUSHALL"])
  end

  defp test_prefix_exists? conn, prefixes do
    prefixes
      |> Autocompletex.Helper.prefixes
      |> Enum.map(
        fn prefix -> 
          case Redix.command(conn, ~w(ZRANK ZSET) ++ [prefix]) do
            {:ok, w} ->
              assert w >= 0
            {:error, err} -> 
              IO.puts err
              assert false
          end
        end) 
  end

  defp prefix_score conn, prefixes do
    prefixes
      |> Autocompletex.Helper.prefixes
      |> Enum.map(fn prefix -> 
          case Redix.command(conn, ["ZSCORE", "ZSET", prefix]) do
            {:ok, msg} ->
              msg
            {:error, err} ->
              IO.inspect err
              assert false
           end
         end)
  end

end