defmodule Autocompletex.Predictive do
  use GenServer

  def start_link(redis, db_prefix \\ "autocompletex", name) do
    GenServer.start_link(__MODULE__, %{:redis => redis, :db_prefix => db_prefix}, [name: name])
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
    %{:redis => redis, :db_prefix => db_prefix} = state

    term = case prefix do
      [t|_h] -> t
      t -> t
    end

    case Redix.command(redis, ["ZCARD", db_prefix <> ":" <> term]) do
      {:ok, 0} ->
        {:reply, {:ok, []}, state}
      {:ok, _} ->
        case Redix.command(redis, ["ZREVRANGEBYSCORE", db_prefix <> ":" <> term, rangelen, "0"]) do
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
    %{:redis => redis, :db_prefix => db_prefix} = state
    terms |> Enum.each(&insertp(&1, redis, db_prefix))
    {:reply, :ok, state}
  end

  defp insertp(term, redis, db_prefix) do
    term
      |> Autocompletex.Helper.prefixes_predictive
      |> Enum.map(fn prefix -> Redix.command(redis, ["ZINCRBY", db_prefix <> ":" <> prefix, "1", term]) end)
    :ok
  end

end
