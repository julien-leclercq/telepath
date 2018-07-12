defmodule Telepath.MixProject do
  use Mix.Project

  def project do
    [
      app: :telepath,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      build_path: "../../_build",
      deps_path: "../../deps",
      lockfile: "../../mix.lock"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ecto_mnesia],
      mod: {Telepath.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:kaur, "~> 1.1.0"},
      {:ecto, "~> 2.1.6"},
      {:ecto_mnesia, "~> 0.9.1"}
    ]
  end
end
