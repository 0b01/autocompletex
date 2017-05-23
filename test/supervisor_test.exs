defmodule AutocompletexLexicographicSupervisorTest do
  use ExUnit.Case
  use Plug.Test
  alias Autocompletex.Web.Lexicographic
  @opts Lexicographic.init([])

  setup do
    conn =
      case Redix.start_link do
        {:ok, conn} ->
          conn
        {:error, {:already_started, pid}} -> 
          pid
      end
    {:ok, redis: conn}
  end

  test "start_link lex", state do
    %{redis: conn} = state
    Autocompletex.Lexicographic.Supervisor.start_link(conn)
  end
  test "start_link pred", state do
    %{redis: conn} = state
    Autocompletex.Predictive.Supervisor.start_link(conn)
  end
end
