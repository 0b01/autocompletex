defmodule Autocompletex.Web do  
  use Plug.Router
  require Logger
  import Plug.Conn

  plug Plug.Logger
  plug :match
  plug :dispatch

  def init(options) do
    {:ok, conn} = Redix.start_link
    {:ok, worker} = Autocompletex.Worker.start_link(conn, Autocompletex.Worker)
    options
  end

  def start_link({:port, port}) do
    {:ok, _} = Plug.Adapters.Cowboy.http Autocompletex.Web, [], port: port
  end

  get "/add" do
    conn = conn |> fetch_query_params
    %{"term" => term} = conn.params
    Autocompletex.Worker.upsert(Autocompletex.Worker, [term])
    conn
    |> send_resp(200, Poison.encode!(term))
    |> halt
  end

  get "/complete" do
    conn = conn |> fetch_query_params
    %{"term" => term} = conn.params
    {:ok, result} = Autocompletex.Worker.complete(Autocompletex.Worker, [term])
    conn
    |> send_resp(200, Poison.encode!(result))
    |> halt
  end

  match _ do  
    conn
    |> send_resp(404, "Nothing here")
    |> halt
  end

end  