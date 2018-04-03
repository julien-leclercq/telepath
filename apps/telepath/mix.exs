defmodule Telepath.MixProject do
  use Mix.Project

  def project do
    [
      app: :telepath,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Telepath.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:kaur, "~> 1.1.0"},
      {:ecto, "~> 2.2.9"}
    ]
  end
end
