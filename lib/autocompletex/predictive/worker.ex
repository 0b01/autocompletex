defmodule Autocompletex.Predictive do
  use GenServer

  def start_link(redis, name) do
    GenServer.start_link(__MODULE__, %{:redis => redis}, [name: name])
  end

  def ping(pid) do
    GenServer.call(pid, {:ping})
  end

  def complete(pid, prefix, rangelen \\ 50) do
    GenServer.call(pid, {:complete, prefix, rangelen})
  end

  def upsert(pid, term) do
    GenServer.call(pid, {:upsert, term})
  end

  # Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call({:ping}, _from, state) do
    %{:redis => redis} = state
    {:ok, pong} = Redix.command(redis, ["PING"])
    {:reply, {:ok, pong}, state}
  end

  def handle_call({:complete, prefix, rangelen}, _from, state) do
    %{:redis => redis} = state
    case Redix.command(redis, ["ZCARD", prefix]) do
      {:ok, "0"} ->
        {:reply, {:ok, []}, state}
      {:ok, _} -> 
        case Redix.command(redis, ["ZRANGE", prefix, "0", rangelen]) do
          {:ok, list} ->
            {:reply, {:ok, list}, state}
          {:error, err} ->
            {:reply, {:error, err}, state}
        end
      {:error, err} -> 
        {:reply, {:error, err}, state}
    end
  end

  def handle_call({:upsert, terms}, _from, state) do
    %{:redis => redis} = state
    terms |> Enum.each(&insertp(&1, redis))
    {:reply, :ok, state}
  end

  defp insertp(term, redis) do
    term
      |> Autocompletex.Helper.prefixes_predictive
      |> Enum.map(fn prefix -> Redix.command(redis, ["ZINCRBY", prefix, "1", term]) end)
    :ok
  end

end