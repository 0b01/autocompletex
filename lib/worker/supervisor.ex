defmodule Autocompletex.Worker.Supervisor do
  use Supervisor

  @name __MODULE__

  def start_link(redis, name \\ @name) do
    Supervisor.start_link(__MODULE__, [redis], [name: name])
  end

  def init(redis) do
  	
    children = [
      worker(Autocompletex.Worker, [redis], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end