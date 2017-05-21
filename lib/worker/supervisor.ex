defmodule Autocompletex.Worker.Supervisor do
  use Supervisor

  def start_link(redis, name \\ nil) do
    Supervisor.start_link(__MODULE__, [redis], name: :worker_supervisor)
  end

  def init(redis) do
    children = [
      worker(Autocompletex.Worker, [redis])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end