defmodule AutocompletexHttpTest do
  use ExUnit.Case
  use Plug.Test
  alias Autocompletex.Web.Lexicographic
 
  @opts Lexicographic.init([])

  test "returns :ok" do
    conn = conn(:get, "/", "")
           |> Lexicographic.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "returns 404" do
    conn = conn(:get, "/missing", "")
           |> Lexicographic.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end


end