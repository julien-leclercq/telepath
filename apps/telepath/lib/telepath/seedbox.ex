defmodule Telepath.Seedbox do
  @moduledoc """
  This module provides data structure and functions to manipulate seedboxes
  """
  alias Kaur.Result
  alias Telepath.Seedbox
  alias Telepath.Seedbox.{Auth, Impl, Repository}
  require Logger
  use Ecto.Schema

  embedded_schema do
    field(:accessible, :boolean, default: false)
    field(:host, :string)
    field(:name, :string, default: "")
    field(:port, :integer)
    field(:remote, :boolean, default: true)
    field(:session, {:map, :string})
    field(:session_id, :string)
    field(:torrents, {:array, :string}, default: [])

    embeds_one(:auth, Auth, on_replace: :update)
  end

  @spec create(map) :: {:ok, %Seedbox{}} | {:error, term()}
  def create(seedbox_params) do
    seedbox_params
    |> Impl.create()
    |> Result.tap_error(fn _ -> Logger.error("SEEDBOX:CREATE invalid data") end)
    |> Result.and_then(fn box ->
      box
      |> Repository.create()
      |> Result.map(fn _ -> box end)
    end)
  end

  def dispatch_call(call) do
    Supervisor.which_children(Seedbox.Supervisor)
    |> Enum.map(fn {_, pid, _, _} -> Task.async(call.(pid)) end)
    |> Enum.map(&Task.await/1)
    |> Result.sequence()
  end

  def get(pid) when is_pid(pid) do
    pid
    |> GenServer.call(:state, :infinity)
  end

  def get(id) when is_binary(id) do
    Repository.find(id)
    |> Result.and_then(fn {pid, _} -> get(pid) end)
  end

  def list() do
    async_get = fn pid ->
      fn -> get(pid) end
    end

    dispatch_call(async_get)
  end

  def update(id, params) do
    id
    |> Repository.find()
    |> Result.either(fn _ -> Result.error(:not_found) end, fn {pid, _} ->
      pid
      |> GenServer.call({:update, params}, :infinity)
    end)
  end

  def delete(id) do
    id
    |> Repository.find()
    |> Result.either(fn _ -> Result.error(:not_found) end, fn {pid, _} ->
      pid
      |> GenServer.stop(:normal)
      |> case do
        :ok -> {:ok, id}
        _ -> Result.error("impossible to stop process (this is not normal)")
      end
    end)
  end
end
