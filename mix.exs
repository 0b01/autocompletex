defmodule Autocompletex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :autocompletex,
      version: "0.1.1",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(), 
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      deps: deps(),
      name: "Autocompletex",
      source_url: "https://github.com/rickyhan/autocompletex"
    ]
  end

  def application do
    [extra_applications: [:logger, :redix, :cowboy, :plug],
     mod: {Autocompletex, []}
    ]
  end

  defp deps do
    [
      {:redix, ">= 0.0.0"},
      {:cowboy, "~> 1.0.3"},
      {:plug, "~> 1.0"},
      {:poison, "~> 3.0"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:excoveralls, "~> 0.6", only: :test}
    ]
  end

  defp description do
    """
    Autocompletex is a low-latency plug and play autocomplete tool using Redis sorted set.
    """
  end

  defp package do
    [
      name: :autocompletex,
      files: ["lib", "test", "mix.exs", "README.md", "config", "doc"],
      maintainers: ["Ricky Han"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/rickyhan/autocompletex"}
    ]
  end
end
