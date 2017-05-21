defmodule Mix.Tasks.Autocompletex.Import do
	use Mix.Task

	def run fname do
		{:ok, lines} = File.read fname

		terms = lines |> String.split("\n")

		# terms
		# |> Enum.map(&(System.cmd("curl", ["localhost:3000/add?term=" <> &1])))

		{:ok, redis} = Redix.start_link
		{:ok, _} = Autocompletex.Lexicographic.start_link(redis, :ac)
		terms
		|> Enum.map(&(Autocompletex.Lexicographic.upsert(:ac, [&1])))
	end
end