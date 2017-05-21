defmodule Autocompletex.Worker do
  use GenServer

  def start_link(redis, name) do
    GenServer.start_link(__MODULE__, redis, [name: name])
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

  def incr(pid, term) do
    GenServer.call(pid, {:incr, term})
  end

  def upsert(pid, term) do
    GenServer.call(pid, {:upsert, term})
  end

  # Callbacks

  def init(redis) do
    {:ok, redis}
  end

  def handle_call({:insert, term}, _from, redis) do
    {:reply, insertp(term, redis), redis}
  end

  def handle_call({:ping}, _from, redis) do
    {:ok, pong} = Redix.command(redis, ["PING"])
    {:reply, {:ok, pong}, redis}
  end

  def handle_call({:complete, prefix, rangelen}, _from, redis) do
    case Redix.command(redis, ["ZRANK", "ZSET", prefix]) do
      {:ok, nil} ->
        {:reply, {:ok, []}, redis}
      {:ok, start} -> 
        case Redix.command(redis, ["zrange", "ZSET", start, start+rangelen]) do
          {:ok, list} ->
            ret = list
              |> Enum.filter(
                &(&1 |> String.last == "*" && 
                  &1 |> String.starts_with?(prefix)))
              |> Enum.map(fn word -> String.slice(word, 0..-2) end)
            {:reply, {:ok, ret}, redis}
          {:error, err} ->
            {:reply, {:error, err}, redis}
        end
      {:error, err} -> 
        {:reply, {:error, err}, redis}
    end
  end

  def handle_call({:incr, term}, _from, redis) do
    {:reply, incrp(term, redis), redis}
  end

  def handle_call({:upsert, term}, _from, redis) do
    term
      |> Enum.each(fn t -> 
          case Redix.command(redis, ["ZRANK", "ZSET", t <> "*"]) do
            {:ok, nil} ->
              insertp(t, redis)
            {:ok, _ } ->
              incrp(t, redis)
            {:error, err} ->
              {:error, err}
          end
        end)
    {:reply, :ok, redis}
  end

  defp insertp(term, redis) do
    term
      |> Autocompletex.Helper.prefixes
      |> Enum.map(fn prefix -> Redix.command(redis, ["ZADD", "ZSET", "0", prefix]) end)
    :ok
  end

  defp incrp(term, redis) do
    term
      |> Autocompletex.Helper.prefixes
      |> Enum.map(fn prefix -> 
        case Redix.command(redis, ["ZINCRBY", "ZSET", "1", prefix]) do
          {:ok, _} -> :ok
          {:error, err} -> {:reply, {:error, err}, redis}
        end
      end)
    :ok
  end

end