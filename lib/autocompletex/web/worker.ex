defmodule Autocompletex.Web do

  def start_link({:port, port}) do
    type = Application.get_env(:autocompletex, :type, :lexicographic)
    case type do
      :lexicographic ->
        {:ok, _} = Plug.Adapters.Cowboy.http Autocompletex.Web.Lexicographic, [], port: port
      :predictive ->
        {:ok, _} = Plug.Adapters.Cowboy.http Autocompletex.Web.Predictive, [], port: port
    end
  end

  def init() do
    :ok
  end

end
