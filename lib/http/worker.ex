defmodule Autocompletex.Web do

  use Plug.Router
  require Logger

  plug Plug.Logger
  plug :match
  plug :dispatch

  def start_link(port, opts \\ []) do
    {:ok, _} = Plug.Adapters.Cowboy.http __MODULE__, []
  end

  def init(options) do
    {:ok, options}
  end

  get "/" do
    conn
    |> send_resp(200, "ok")
    |> halt
  end

end