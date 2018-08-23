defmodule Koop.App do
  use Application

  def start(_type, _args) do
    repo = %{
      id: Koop.Repo,
      start: {Koop.Repo, :start_link, []}
    }

    Supervisor.start_link([repo], strategy: :one_for_one)
  end
end
