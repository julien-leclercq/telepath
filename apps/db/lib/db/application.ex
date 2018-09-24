defmodule DB.Application do
  use Application

  def start(_type, _args) do
    repo = %{
      id: DB.Repo,
      start: {DB.Repo, :start_link, []}
    }

    Supervisor.start_link([repo], strategy: :one_for_one)
  end

end
