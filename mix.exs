defmodule Cielo.MixProject do
  use Mix.Project

  @version "0.1.8"
  def project do
    [
      app: :cielo,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],

      # Hex
      description: "A Client for Cielo E-Commerce API",
      package: package(),

      # Docs
      name: "Cielo",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Cielo.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hackney, "~> 1.15"},
      {:jason, "~> 1.2"},
      {:ecto, "~> 3.2"},
      {:telemetry, "~> 0.4"},
      {:excoveralls, "~> 0.13.0", only: [:dev, :test]},
      {:mox, "~> 1.0", only: :test},
      {:inch_ex, github: "rrrene/inch_ex", only: [:dev, :test]},
      {:ex_doc, "~> 0.22", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Bruno Louvem"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/brunolouvem/cielo"},
      files: ~w(.formatter.exs mix.exs README.md CHANGELOG.md lib)
    ]
  end

  defp docs do
    [
      main: "Cielo",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/cielo",
      source_url: "https://github.com/brunolouvem/cielo",
      extras: ["README.md", "CHANGELOG.md"],
      groups_for_extras: [Extras: ~r{^CHANGELOG.md}]
    ]
  end
end
