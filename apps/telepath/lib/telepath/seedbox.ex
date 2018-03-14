defmodule Telepath.Seedbox do
  @moduledoc """
  This module provides data structure and functions to manipulate seedboxes
  """
  use Ecto.Schema

  embedded_schema do
    field(:host, :string)
    field(:name, :string)
    field(:port, :string)
    field(:accessible, :boolean)
  end

  def update(seedbox, params) do
    {:ok, Map.merge(seedbox, params)}
  end
end
