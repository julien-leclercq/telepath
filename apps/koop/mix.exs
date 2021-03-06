defmodule FlacMetaReader.Mixfile do
  use Mix.Project

  def project do
    [
      app: :koop,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      build_path: "../../_build",
      deps_path: "../../deps",
      lockfile: "../../mix.lock"
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [mod: {Koop.App, []}, extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ffmpex, "~> 0.5.2"},
      {:kaur, "~> 1.1.0"},

      # internal
      {:db, in_umbrella: true},
      # Test only
      {:response_snapshot, "~> 1.0.0", only: [:test]},

      # NOT RUNTIME
      {:credo, "~> 0.9", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end
end
