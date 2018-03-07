defmodule Telepath.Seedbox do
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
