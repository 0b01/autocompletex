defmodule Autocompletex.Predictive.Supervisor do
  use Supervisor

  def start_link(redis) do
    Supervisor.start_link(__MODULE__, redis, name: __MODULE__)
  end

  def init(redis) do
    children = [
      worker(Autocompletex.Predictive, [redis, Autocompletex.Predictive] )
    ]

    supervise(children, strategy: :one_for_one)
  end
end

