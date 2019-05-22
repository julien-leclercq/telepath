defmodule Koop.App do
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
      }
    ]

    Logger.info("starting koop")
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
