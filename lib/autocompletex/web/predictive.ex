defmodule Autocompletex.Web.Predictive do  
  use Plug.Router
  require Logger
  import Plug.Conn

  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/" do
    conn |> send_resp(200, "predictive - :ok") |> halt
  end

  get "/add" do
    conn = conn |> fetch_query_params
    %{"term" => term} = conn.params
    Autocompletex.Predictive.upsert(Autocompletex.Predictive, [term])
    conn
    |> send_resp(200, Poison.encode!(term))
    |> halt
  end

  get "/complete" do
    conn = conn |> fetch_query_params
    %{"term" => term} = conn.params
    {:ok, result} = Autocompletex.Predictive.complete(Autocompletex.Predictive, [term])
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