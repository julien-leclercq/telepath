defmodule Telepath.Application do
  use Application

  require Logger

  def start(_, _) do
    children = [
      %{
        id: Library.InfosFetcher.Supervisor,
        start: {
          Library.InfosFetcher.Supervisor,
          :start_link,
          []
        }
      },
      %{id: WebWeb.Endpoint, start: {WebWeb.Endpoint, :start_link, []}},
      %{
        id: Telepath.Seedbox.Repository,
        start: {Telepath.Seedbox.Repository, :start_link, []},
        type: :supervisor
      },
      %{
        id: DB.Repo,
        start: {DB.Repo, :start_link, []}
      }
    ]

    Logger.info("starting koop")
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
