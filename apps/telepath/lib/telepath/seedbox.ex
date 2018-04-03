defmodule Telepath.Seedbox do
  @moduledoc """
  This module provides data structure and functions to manipulate seedboxes
  """
  alias Kaur.Result
  alias Telepath.Seedbox.{Impl, Repository}
  require Logger
  use Ecto.Schema

  embedded_schema do
    field(:accessible, :boolean, default: false)
    field(:host, :string)
    field(:name, :string, default: "")
    field(:port, :integer)
    field(:remote, :boolean, default: true)
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
end
