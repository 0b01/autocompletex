defmodule Autocompletex.Mixfile do
  use Mix.Project

  def project do
    [app: :autocompletex,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger, :redix, :cowboy, :plug]]
  end

  defp deps do
    [
      {:redix, ">= 0.0.0"},
      {:cowboy, "~> 1.0.3"},
      {:plug, "~> 1.0"}
    ]
  end
end
