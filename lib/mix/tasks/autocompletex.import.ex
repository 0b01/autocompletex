defmodule Mix.Tasks.Autocompletex.Import do
  use Mix.Task

  def run opts do
    {:ok, fname, predictive} =  
      case OptionParser.parse(opts, switches: [filename: :string, predictive: :boolean]) do
        {[filename: fname, predictive: _], _, _} -> 
          {:ok, fname, true}

        {[filename: fname], _, _} ->
          {:ok, fname, false}
        x ->
          IO.puts "mix autocompletex.import --filename [path/to/file] [--predictive]"
          {:error, "wrong format"}
      end

    {:ok, lines} = File.read fname
    terms = lines |> String.split("\n")

    redis =
      case Redix.start_link do
        {:ok, redis} -> redis
        {:error, {:already_started, redis}} -> redis
      end

    module = if predictive do
      Autocompletex.Predictive
    else
      Autocompletex.Lexicographic
    end

    module.start_link(redis, :ac)

    terms
    |> Enum.map(&(module.upsert(:ac, [&1])))

  end
end