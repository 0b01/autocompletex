defmodule Autocompletex do
  use Application
  @name :autocompletex
  def start _type, _args do
    import Supervisor.Spec, warn: false
    redix = worker(Redix, [[host: config(:redis_host, "localhost"), port: config(:redis_port, 6379)], [name: :autocomplete_redis]])
    supervisor =
      case config(:type, :lexicographic) do
        :lexicographic ->
          supervisor(Autocompletex.Lexicographic.Supervisor, [:autocomplete_redis])
        :predictive ->
          supervisor(Autocompletex.Predictive.Supervisor, [:autocomplete_redis])
      end

    children =

      if config(:http_server, true) do
        [
          redix,
          worker(Autocompletex.Web, [port: config(:http_port, 3000)]),
          supervisor
        ]
      else
        [
          redix,
          supervisor
        ]
      end

    if config(:debug, false), do: :observer.start

    Supervisor.start_link(children, [name: @name, strategy: :one_for_one])

  end

  defp config(key, default) do
    Application.get_env(:autocompletex, key, default)
  end

end
