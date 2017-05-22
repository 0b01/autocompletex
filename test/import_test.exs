defmodule AutocompletexMixTaskTest do
  use ExUnit.Case

  setup do
    conn = 
      case Redix.start_link do
        {:ok, conn} ->
          conn
        {:error, {:already_started, conn}} ->
          conn
      end

    worker =
      case Autocompletex.Lexicographic.start_link(conn, 'testdb2', :ac) do
        {:ok, worker} ->
          worker
        {:error, {:already_started, worker}} ->
          worker
      end

    {:ok, worker: worker, redis: conn}
  end

  test "import file", state do

    %{worker: worker, redis: conn} = state

    Mix.Tasks.Autocompletex.Import.run(["--filename", "test/female-names.txt"])

    expected = ["teresa", "terese", "teresina", "teresita", "teressa"]
    assert {:ok, expected} == Autocompletex.Predictive.complete(worker, "teres") 

    Redix.command(conn, ["FLUSHALL"])
  end


end
