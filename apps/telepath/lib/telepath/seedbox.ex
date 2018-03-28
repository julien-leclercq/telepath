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

    embeds_one(:auth, Auth, on_replace: :update)
  end

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

  def get(pid) when is_pid(pid) do
    pid
    |> GenServer.call(:state, :infinity)
  end

  def get(id) when is_binary(id) do
    Repository.find(id)
    |> Result.and_then(fn {pid, _} -> get(pid) end)
  end

  def list() do
    async_get = fn {_, pid, _, _} ->
      Task.async(fn -> get(pid) end)
    end

    Supervisor.which_children(Seedbox.Supervisor)
    |> Enum.map(async_get)
    |> Enum.map(&Task.await/1)
    |> Result.sequence()
  end

  def update(id, params) do
    id
    |> Repository.find()
    |> Result.either(fn _ -> Result.error(:not_found) end, fn {pid, _} ->
      pid
      |> GenServer.call({:update, params}, :infinity)
    end)
  end
end
