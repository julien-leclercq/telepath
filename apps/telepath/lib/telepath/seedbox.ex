defmodule Telepath.Seedbox do
  @moduledoc """
  This module provides data structure and functions to manipulate seedboxes
  """

  defstruct [
    :id,
    :url,
    :port,
    :name
  ]

  def update(seedbox, params) do
    {:ok, Map.merge(seedbox, params)}
  end
end
