defmodule Autocompletex.Helper do
  def prefixes_lexicographic l do
    l |> prefixes |> List.flatten |> Enum.map(fn w ->
      if Enum.member?(List.flatten([l]), w) do w <> "*" else w end
    end)
  end

  def prefixes_predictive l do
    l |> prefixes |> List.flatten
  end

  defp prefixes l do
    case l do
      [h|r] ->
        [(prefixes h) | (prefixes r)]
      [] ->
        []
      _ -> # binary string
        charlist = l |> String.graphemes
        Enum.scan(charlist, [], &([&1 | &2] ))
          |> Enum.map(fn l ->
            l
              |> Enum.reverse
              |> Enum.join("")
            end)
    end
  end
end
