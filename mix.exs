defmodule TransmissionUi.Mixfile do
  use Mix.Project

  def project do
    [
      app: :telepath,
      build_embedded: Mix.env() == :prod,
      build_path: "_build",
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      config_path: "config/config.exs",
      deps: deps(),
      deps_path: "deps",
      elixir: "~> 1.8.1",
      lockfile: "mix.lock",
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  defp deps do
    [
      {:ecto, "~> 2.2.12"},
      # {:ecto_mnesia, "~> 0.9.1"},
      {:ffmpex, "~> 0.5.2"},
      {:httpoison, "~> 1.0"},
      {:gettext, "~> 0.16.1"},
      {:kaur, "~> 1.1.0"},
      {:phoenix, "~> 1.4.0"},
      {:phoenix_ecto, "~> 3.6.0"},
      {:phoenix_html, "~> 2.13.2"},
      {:phoenix_live_reload, "~> 1.2.0", only: :dev},
      {:phoenix_pubsub, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.8.0"},
      {:sqlite_ecto2, "~> 2.2.4"},

      # Test only
      {:response_snapshot, "~> 1.0.0", only: [:test]},

      # NOT RUNTIME
      {:credo, "~> 0.9", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.20.2", only: :dev, runtime: false}
    ]
  end
end
