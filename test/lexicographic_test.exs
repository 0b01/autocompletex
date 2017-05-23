defmodule AutocompletexInsertTest do
  use ExUnit.Case
  doctest Autocompletex
  import Autocompletex.Lexicographic

  setup do
    {:ok, conn} = Redix.start_link
    db = "testdb"
    {:ok, worker} = start_link(conn, db, :ac)
    {:ok, worker: worker, redis: conn, db: db} 
  end

  test "insert a prefix string", state do
    %{worker: worker, redis: conn, db: db} = state
    :ok = insert(worker, ["test", "example"])
    test_prefix_exists? conn, ["test", "example"], db
    Redix.command(conn, ["FLUSHALL"])
  end

  test "autocomplete a prefix", state do
    %{worker: worker, redis: conn} = state
    :ok = insert(worker, ["test", "example"])
    assert complete(worker, "te") == {:ok, ["test"]}
    assert complete(worker, ["ex"]) == {:ok, ["example"]}
    Redix.command(conn, ["FLUSHALL"])
  end

  test "upsert a term - insert",state do
    %{worker: worker, redis: conn, db: db} = state
    :ok = upsert(worker, ["test", "example"])
    test_prefix_exists? conn, ["test", "example"], db
    Redix.command(conn, ["FLUSHALL"])
  end

  defp test_prefix_exists? conn, prefixes, db do
    prefixes
    |> Autocompletex.Helper.prefixes_lexicographic
    |> Enum.map(
        fn prefix -> 
          case Redix.command(conn, ["ZRANK", db, prefix]) do
            {:ok, w} ->
              assert w >= 0
            {:error, err} -> 
              IO.puts err
              assert false
          end
        end) 
  end

end
