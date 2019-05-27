# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :db, ecto_repos: [DB.Repo]

config :db, DB.Repo, adapter: Sqlite.Ecto2

config :mnesia,
  dir: '../../priv/data/mnesia'
