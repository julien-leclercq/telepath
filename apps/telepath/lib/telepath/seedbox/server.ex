defmodule Telepath.Seedbox.Server do
  @moduledoc """
  This module provides a state holding feature per seedbox
  """
  # alias Kaur.Result
  alias Telepath.Seedbox
  require Logger
  use GenServer

  def start_link(seedbox, options \\ []) do
    # Logger.info fn _ -> "Telepath.Seedbox.starting #{seedbox.id}" end
    GenServer.start_link(__MODULE__, seedbox, options)
  end

  def init(%Seedbox{} = seedbox) do
    {:ok, seedbox, :infinity}
  end
end
