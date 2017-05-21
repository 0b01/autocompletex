defmodule Autocompletex do
  use Application
  @name :autocompletex
  def start do
    import Supervisor.Spec, warn: false

    children = if config(:http_server, true), do: [
      supervisor(Autocompletex.Worker.Supervisor, [:redix]),
      supervisor(Autocompletex.HTTP.Supervisor, [port: get_port()]),
      worker(Redix, [[], [name: :redix]]),
    ], else: [
      supervisor(Autocompletex.Worker.Supervisor, [:redix]),
      worker(Redix, [[], [name: :redix]])
    ]

    if config(:debug, false), do: :observer.start

    Supervisor.start_link(children, [name: @name, strategy: :one_for_one])
 
  end

  def get_port do
    config(:http_port, 3000)
  end


  defp config(key, default \\ nil) do
    Application.get_env(:autocompletex, key, default)
  end

end