defmodule AutocompletexPredictiveTest do
  use ExUnit.Case
  doctest Autocompletex
  import Autocompletex.Predictive

  setup do
    db_prefix = "autocomplete"
    conn =
      case Redix.start_link do
        {:ok, conn} -> conn
        _           -> nil
      end
    worker =
      case start_link(conn, db_prefix, :ac) do
        {:ok, worker} -> worker
        _             -> nil
      end
    {:ok, worker: worker, db_prefix: db_prefix, redis: conn}
  end

  test "insert a prefix string", state do
    %{worker: worker, redis: conn, db_prefix: db_prefix} = state
    :ok = upsert(worker, ["test", "example"])
    test_prefix_exists? conn, ["test", "example"], db_prefix
    Redix.command(conn, ["FLUSHALL"])
  end

  test "autocomplete a prefix", state do
    %{worker: worker, redis: conn, db_prefix: db_prefix} = state
    :ok = upsert(worker, ["test", "example"])
    assert complete(worker, "te") == {:ok, ["test"]}
    assert complete(worker, "ex") == {:ok, ["example"]}
    Redix.command(conn, ["FLUSHALL"])
  end

  test "upsert a term - insert", state do
    %{worker: worker, redis: conn, db_prefix: db_prefix} = state
    :ok = upsert(worker, ["test", "example"])
    test_prefix_exists? conn, ["test", "example"], db_prefix
    Redix.command(conn, ["FLUSHALL"])
  end

  test "upsert a term - incr", state do
    %{worker: worker, redis: conn, db_prefix: db_prefix} = state

    :ok = upsert(worker, ["test", "example"])
    before_score = get_score conn, ["test", "example"], db_prefix
    :ok = upsert(worker, ["test", "example"])
    after_score = get_score conn, ["test", "example"], db_prefix

    Enum.zip(before_score, after_score)
    |> Enum.map(fn {a,b} ->
      Enum.zip(a,b)
      |> Enum.map(
        fn {a,b} -> String.to_integer(b) - String.to_integer(a) == 1 end)
      |> Enum.all?
    end)
    |> Enum.all?

    Redix.command(conn, ["FLUSHALL"])
  end

  defp get_score conn, terms, db_prefix do
    terms
    |> Enum.map(fn term ->
      term
      |> Autocompletex.Helper.prefixes_predictive
      |> Enum.map(fn prefix ->
          case Redix.command(conn, ["ZSCORE", db_prefix <> ":" <> prefix, term]) do
            {:ok, w} ->
              w
            {:error, err} ->
              IO.puts err
              assert false
          end
        end)
    end)
  end

  defp test_prefix_exists? conn, terms, db_prefix do
    terms
    |> Autocompletex.Helper.prefixes_predictive
    |> Enum.map(
        fn prefix ->
          case Redix.command(conn, ["ZCARD", db_prefix <> prefix]) do
            {:ok, w} ->
              assert w >= 0
            {:error, err} ->
              IO.puts err
              assert false
          end
        end) 
  end

end
