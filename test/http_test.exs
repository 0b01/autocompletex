defmodule AutocompletexLexicographicHTTPTest do
  use ExUnit.Case
  use Plug.Test
  alias Autocompletex.Web.Lexicographic
  @opts Lexicographic.init([])

  setup do
    db_prefix = "autocomplete"
    conn =
      case Redix.start_link do
        {:ok, conn} ->
          conn
        {:error, {:already_started, pid}} -> 
          pid
      end
    worker =
      case Autocompletex.Lexicographic.start_link(conn, db_prefix, Autocompletex.Lexicographic) do
        {:ok, worker} ->
          worker
        {:error, {:already_started, pid}} ->
          pid
      end
    {:ok, worker: worker, db_prefix: db_prefix, redis: conn}
  end

  test "returns :ok" do
    conn = conn(:get, "/ok", "")
           |> Lexicographic.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "returns 404" do
    conn = conn(:get, "/missing", "")
           |> Lexicographic.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end

  test "add term", state do
    %{worker: worker} = state
    conn(:get, "/add?term=test", "")
           |> Lexicographic.call(@opts)
    conn = conn(:get, "/add?term=example", "")
           |> Lexicographic.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200

    assert Autocompletex.Lexicographic.complete(worker, "te") == {:ok, ["test"]}
    assert Autocompletex.Lexicographic.complete(worker, "ex") == {:ok, ["example"]}
  end

  test "complete" do
    
    conn = conn(:get, "/add?term=test", "")
           |> Lexicographic.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200

    conn = conn(:get, "/add?term=example", "")
           |> Lexicographic.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200

    conn = conn(:get, "/complete?term=test", "")
           |> Lexicographic.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200

    conn = conn(:get, "/complete?term=example", "")
           |> Lexicographic.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200

  end
end

defmodule AutocompletexPredictiveHTTPTest do
  use ExUnit.Case
  use Plug.Test
  alias Autocompletex.Web.Predictive
  @opts Predictive.init([])

  setup do
    db_prefix = "autocomplete"
    conn =
      case Redix.start_link do
        {:ok, conn} ->
          conn
        {:error, {:already_started, pid}} -> 
          pid
      end
    worker =
      case Autocompletex.Predictive.start_link(conn, db_prefix, Autocompletex.Predictive) do
        {:ok, worker} ->
          worker
        {:error, {:already_started, pid}} ->
          pid
      end
    {:ok, worker: worker, db_prefix: db_prefix, redis: conn}
  end

  test "returns :ok" do
    conn = conn(:get, "/ok", "")
           |> Predictive.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "returns 404" do
    conn = conn(:get, "/missing", "")
           |> Predictive.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end


  test "add term", state do
    %{worker: worker} = state
    conn(:get, "/add?term=test", "")
      |> Predictive.call(@opts)
    conn = conn(:get, "/add?term=example", "")
           |> Predictive.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200

    assert Autocompletex.Predictive.complete(worker, "te") == {:ok, ["test"]}
    assert Autocompletex.Predictive.complete(worker, "ex") == {:ok, ["example"]}
  end

  test "complete" do

    conn = conn(:get, "/add?term=test", "")
           |> Predictive.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200

    conn = conn(:get, "/add?term=example", "")
           |> Predictive.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200

    conn = conn(:get, "/complete?term=test", "")
           |> Predictive.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200

    conn = conn(:get, "/complete?term=example", "")
           |> Predictive.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200

  end

end
