defmodule Web.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(WebWeb.Endpoint, []),
    ]

    opts = [strategy: :one_for_one, name: Web.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    WebWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
