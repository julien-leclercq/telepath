defmodule Telepath.Seedbox.Repository do
  @moduledoc """
  A registry to hold seedbox genservers
  """
  alias Kaur.Result
  alias Telepath.Data.Seedbox
  require Logger
  use Supervisor
  @registry :seedbox_repository

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      %{
        id: @registry,
        start: {Registry, :start_link, [[keys: :unique, name: @registry]]}
      },
      %{
        id: Seedbox.Supervisor,
        start: {Telepath.Seedbox.Supervisor, :start_link, []},
        type: :supervisor
      }
    ]

    Logger.info("STARTING REPOSITORY")
    Supervisor.init(children, strategy: :one_for_one, name: __MODULE__)
  end

  def create(%Seedbox{} = seedbox) do
    supervisor_pid = find_supervisor_pid(__MODULE__)
    registry_name = {:via, Registry, {@registry, seedbox.id}}

    supervisor_pid
    |> Telepath.Seedbox.Supervisor.start_child(seedbox, registry_name)
    |> Result.tap_error(fn _ -> Logger.error("REPOSITORY:CREATE unable to create seedbox") end)
  end

  def find(seedbox_id) do
    case Registry.lookup(@registry, seedbox_id) do
      [] -> Result.error(:not_found)
      [seedbox_server | _] -> Result.ok(seedbox_server)
    end
  end

  defp find_supervisor_pid(repository_pid) do
    repository_pid
    |> Supervisor.which_children()
    |> Enum.find_value(fn
      {Seedbox.Supervisor, supervisor_pid, _, _} -> supervisor_pid
      _ -> nil
    end)
  end
end
