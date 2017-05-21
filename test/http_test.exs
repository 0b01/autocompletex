defmodule AutocompletexHttpTest do
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
  end
    

end