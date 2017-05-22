defmodule Autocompletex.Lexicographic.Supervisor do
  use Supervisor
  @name __MODULE__
  def start_link(redis) do
    Supervisor.start_link(__MODULE__, redis, name: @name)
  end

  def init(redis) do
    children = [
      worker(Autocompletex.Lexicographic, [redis, 'dbname', Autocompletex.Lexicographic] )
    ]

    supervise(children, strategy: :one_for_one)
  end
end

