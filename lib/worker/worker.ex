defmodule Autocompletex.Worker do

  use GenServer

  def start_link(redis, opts \\ []) do
    GenServer.start_link(__MODULE__, redis, opts)
  end


  def ping(pid) do
    GenServer.call(pid, {:ping})
  end

  def insert(pid, quoted_words) do
  	GenServer.call(pid, {:insert, quoted_words})
  end

  # Callbacks

  def init(redis) do
    {:ok, redis}
  end

  def handle_call({:insert, quoted_words}, _from, redis) do
  	quoted_words
      |> Autocompletex.Helper.prefixes
      |> Enum.map(fn prefix -> Redix.command(redis, ~w(ZADD ZSET 0) ++ [prefix]) end)
    {:reply, :ok, redis}
  end

  def handle_call({:ping}, _from, redis) do
  	{:ok, pong} = Redix.command(redis, ~w(PING))
  	{:reply, {:ok, pong}, redis}
  end

end