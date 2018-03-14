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

  def handle_call({:update, params}, _from, state) do
    case Seedbox.update(state, params) do
      {:ok, new_state} -> {:reply, :ok, new_state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end
end
