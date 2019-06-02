# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# By default, the umbrella project as well as each child
# application will require this configuration file, ensuring
# they all use the same configuration. While one could
# configure all applications here, we prefer to delegate
# back to each application for organization purposes.
import_config "../apps/*/config/config.exs"

# Sample configuration (overrides the imported configuration above):

config :logger, :console,
  level: :info,
  format: "$date $time [$level] $metadata$message\n"

config :db, ecto_repos: [DB.Repo]
config :telepath, ecto_repos: [Telepath.Repo]

config :db, DB.Repo, adapter: Sqlite.Ecto2

config :telepath, Telepath.Repo, adapter: Sqlite.Ecto2

config :web, namespace: Web

# Configures the endpoint
config :web, WebWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "rO7BXmfmnblTorOglPkF9krVUcvNdXgS5RIaAVSzp138jQ0PZ4HHqjImxW5laLd0",
  render_errors: [view: WebWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Web.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]
