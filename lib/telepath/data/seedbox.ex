defmodule Telepath.Data.Seedbox do
  @moduledoc """
  This module provides data structure and functions to manipulate seedboxes
  """

  alias Ecto.Changeset
  alias Kaur.Result
  alias Telepath.Seedbox
  alias Telepath.Seedbox.{Auth, Impl, Repository}

  import Changeset

  use Ecto.Schema

  require Logger

  @max_port :math.pow(2, 16) - 1
  @min_port 0
  @params [:host, :id, :name, :port]
  @required_params [:host, :port]

  schema "seedboxes" do
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

  @spec changeset(%__MODULE__{}, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = seedbox, params) do
    seedbox
    |> cast(params, @params)
    |> validate_required(@required_params)
    |> validate_number(:port, greater_than: @min_port)
    |> validate_number(:port, less_than: @max_port)
    |> cast_embed(:auth, with: &auth_changeset/2)
  end

  @spec create(map) :: {:ok, %__MODULE__{}} | {:error, term()}
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

  # ---- Private ----

  defp auth_changeset(auth, params) do
    auth
    |> cast(params, [:username, :password])
  end
end
