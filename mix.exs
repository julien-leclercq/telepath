defmodule TransmissionUi.Mixfile do
  use Mix.Project

  def project do
    [
      app: :telepath_legacy_umbrella,
      version: "0.1.0",
      build_path: "build",
      config_path: "config/config.exs",
      deps_path: "deps",
      lockfile: "mix.lock",
      elixir: "~> 1.8.1",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.1.3"},
      # {:ecto_mnesia, "~> 0.9.1"},
      {:ffmpex, "~> 0.5.2"},
      {:httpoison, "~> 1.0"},
      {:gettext, "~> 0.16.1"},
      {:kaur, "~> 1.1.0"},
      {:phoenix, "~> 1.4.0"},
      {:phoenix_ecto, "~> 4.0.0"},
      {:phoenix_html, "~> 2.13.2"},
      {:phoenix_live_reload, "~> 1.2.0", only: :dev},
      {:phoenix_pubsub, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.8.0"},

      # Test only
      {:response_snapshot, "~> 1.0.0", only: [:test]},

      # NOT RUNTIME
      {:credo, "~> 0.9", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.20.2", only: :dev, runtime: false}
    ]
  end
end
