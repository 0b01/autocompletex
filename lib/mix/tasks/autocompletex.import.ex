defmodule Mix.Tasks.Autocompletex.Import do
	use Mix.Task

	def run opts do
		
		{[filename: fname, predictive: predictive], _, _} = OptionParser.parse(opts, switches: [filename: :string, predictive: :boolean])

		{:ok, lines} = File.read fname
		terms = lines |> String.split("\n")

		{:ok, redis} = Redix.start_link

		module = if predictive do
			Autocompletex.Predictive
		else
			Autocompletex.Lexicographic
		end

		{:ok, _} = module.start_link(redis, :ac)

		terms
		|> Enum.map(&(module.upsert(:ac, [&1])))

	end
end