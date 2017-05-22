defmodule Autocompletex.Lexicographic do
  use GenServer

  def start_link(redis, db \\ "autocompletex", name) do
    GenServer.start_link(__MODULE__, %{:redis => redis, :db => db}, [name: name])
  end

  def ping(pid) do
    GenServer.call(pid, {:ping})
  end

  def insert(pid, quoted_words) do
    GenServer.call(pid, {:insert, quoted_words})
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

  def handle_call({:insert, term}, _from, state) do
    %{:redis => redis, :db => db} = state
    {:reply, insertp(term, redis, db), state}
  end

  def handle_call({:ping}, _from, state) do
    %{:redis => redis} = state
    {:ok, pong} = Redix.command(redis, ["PING"])
    {:reply, {:ok, pong}, state}
  end

  def handle_call({:complete, prefix, rangelen}, _from, state) do
    %{:redis => redis, :db => db} = state
    term = case prefix do
      [h|t] -> h
      h -> h
    end
    case Redix.command(redis, ["ZRANK", db, term]) do
      {:ok, nil} ->
        {:reply, {:ok, []}, state}
      {:ok, start} -> 
        case Redix.command(redis, ["zrange", db, start, start+rangelen]) do
          {:ok, list} ->
            ret = list
              |> Enum.filter(
                &(&1 |> String.last == "*" && 
                  &1 |> String.starts_with?(prefix)))
              |> Enum.map(fn word -> String.slice(word, 0..-2) end)
            {:reply, {:ok, ret}, state}
          {:error, err} ->
            {:reply, {:error, err}, state}
        end
      {:error, err} -> 
        {:reply, {:error, err}, state}
    end
  end

  def handle_call({:upsert, term}, _from, state) do
    %{:redis => redis, :db => db} = state
    term
      |> Enum.each(fn t -> 
          case Redix.command(redis, ["ZRANK", db, t <> "*"]) do
            {:ok, _ } ->
              insertp(t, redis, db)
            {:error, err} ->
              {:error, err}
          end
        end)
    {:reply, :ok, state}
  end

  defp insertp(term, redis, db) do
    term
      |> Autocompletex.Helper.prefixes_lexicographic
      |> Enum.map(fn prefix -> Redix.command(redis, ["ZADD", db, "0", prefix]) end)
    :ok
  end

end