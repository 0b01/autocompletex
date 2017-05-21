defmodule Autocompletex do
  use Application

  @name :autocompletex
  def start _type, _args do
    import Supervisor.Spec, warn: false

    children =

      if config(:http_server, true) do
        [
          worker(Redix, [[], [name: :redix]]),
          supervisor(Autocompletex.Lexicographic.Supervisor, [:redix]),
          worker(Autocompletex.Web, [port: config(:http_port, 3000)])
        ]
      else 
        [
          worker(Redix, [[], [name: :redix]]),
          case config(:type, :lexicographic) do
            :lexicographic ->
              supervisor(Autocompletex.Lexicographic.Supervisor, [:redix])
            :predictive
              supervisor(Autocompletex.Predictive.Supervisor, [:redix])
          end
        ]
      end

    if config(:debug, false), do: :observer.start

    Supervisor.start_link(children, [name: @name, strategy: :one_for_one])
 
  end

  defp config(key, default) do
    Application.get_env(:autocompletex, key, default)
  end

end