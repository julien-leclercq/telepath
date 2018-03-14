defmodule Telepath.Seedbox do
  @moduledoc """
  This module provides data structure and functions to manipulate seedboxes
  """
  alias Kaur.Result
  alias Telepath.Seedbox.{Impl, Repository}
  require Logger
  use Ecto.Schema

  embedded_schema do
    field(:host, :string)
    field(:name, :string)
    field(:port, :string)
    field(:accessible, :boolean)
  end

  def create(seedbox_params) do
    seedbox_params
    |> Impl.create()
    |> Result.tap_error(fn _ -> Logger.error("SEEDBOX:CREATE invalid data") end)
    |> Result.and_then(fn box ->
      box
      |> Repository.create()
      |> Result.and_then(fn _ -> {:ok, box} end)
    end)
  end
end
