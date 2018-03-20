defmodule Telepath.Seedbox.Supervisor do
  @moduledoc """
  a dynamic supervisor to spawn and manage Seedbox workers
  """
  alias Kaur.Result
  alias Telepath.Seedbox.Server
  require Logger
  use DynamicSupervisor

  def start_link() do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(supervisor, %Telepath.Seedbox{} = seedbox, name_from_repo) do
    child_spec = %{
      id: {Seedbox, seedbox.id},
      start: {Server, :start_link, [seedbox, [name: name_from_repo]]},
      restart: :transient
    }

    supervisor
    |> DynamicSupervisor.start_child(child_spec)
    |> Result.tap_error(fn _ ->
      Logger.error("Telepath.Supervisor.start_child via #{inspect(supervisor)} failed")
    end)
  end
end
