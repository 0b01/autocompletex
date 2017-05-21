defmodule Autocompletex.HTTP.Supervisor do
  use Supervisor

  @name __MODULE__

  def start_link(port, name \\ @name) do
    Supervisor.start_link(__MODULE__, [port], [name: name])
  end

  def init(port) do
  	
    children = [
      worker(Autocompletex.Web, [port], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end