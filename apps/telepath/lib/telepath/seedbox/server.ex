defmodule Telepath.Seedbox.Server do
  @moduledoc """
  This module provides a state holding feature per seedbox
  """
  alias Kaur.Result
  alias Telepath.Seedbox
  alias Telepath.Seedbox.Impl
  require Logger
  use GenServer

  def start_link(seedbox, options \\ []) do
    # Logger.info fn _ -> "Telepath.Seedbox.starting #{seedbox.id}" end
    GenServer.start_link(__MODULE__, seedbox, options)
  end

  def init(%Seedbox{} = seedbox) do
    {:ok, seedbox, :infinity}
  end

  def handle_call(:state, _from, state) do
    {:reply, Result.ok(state), state}
  end

  def handle_call({:update, params}, _from, state) do
    state
    |> Impl.update(params)
    |> Result.either(fn reason -> {:reply, Result.error(reason), state} end, fn value ->
      {:reply, Result.ok(value), value}
    end)
  end
end
