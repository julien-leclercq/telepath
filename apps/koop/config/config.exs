# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :koop, ecto_repos: [Koop.Repo]

config :koop, Koop.Repo, adapter: EctoMnesia.Adapter

config :mnesia, :dir, 'priv/data/mnesia'
