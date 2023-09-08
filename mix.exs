defmodule Plausible.MixProject do
  use Mix.Project

  def project do
    [
      app: :plausible,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      description: description(),
      package: package(),
      name: "Plausible Analytics",
      source_url: "https://github.com/blisscs/plausible",
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/plausible.plt"},
        plt_core_path: "priv/plts/core.plt"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:finch, "~> 0.16.0"},
      {:bypass, "~> 2.1.0", only: :test},
      {:jason, "~> 1.0"},
      {:ex_doc, "~> 0.30.5", only: :dev, runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description() do
    "Elixir library to push events to Plausible Analytics."
  end

  defp package() do
    [
      name: "plausible",
      links: %{"Github" => "https://github.com/blisscs/plausible"},
      licenses: ["Unlicense"]
    ]
  end
end
