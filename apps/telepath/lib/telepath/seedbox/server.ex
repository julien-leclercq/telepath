defmodule Telepath.Seedbox.Server do
  alias Telepath.Seedbox
  use GenServer

  def start_link(%Seedbox{} = seedbox, options \\ [] ) do
    GenServer.start_link(__MODULE__, seedbox, options)
  end

  def update(pid, %Seedbox{} = seedbox) do
    GenServer.call(pid, {:update seedbox})
  end

  def handle_call({:update, params}, _from, state) do
    case Seedbox.update(state, params) do
      {:ok, new_state} -> {:reply, :ok, new_state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

end
