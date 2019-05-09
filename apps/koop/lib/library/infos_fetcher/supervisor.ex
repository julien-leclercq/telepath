defmodule Library.InfosFetcher.Supervisor do
  use Elixir.Supervisor

  require Logger

  def start_link(), do: Supervisor.start_link(__MODULE__, [], name: __MODULE__)

  @impl true
  def init(_) do
    dispatcher = %{
      id: Library.InfosFetcher.Dispatcher,
      start: {
        Library.InfosFetcher.Dispatcher,
        :start_link,
        []
      }
    }

    Supervisor.init(
      [
        dispatcher
      ],
      strategy: :one_for_one
    )
  end
end
