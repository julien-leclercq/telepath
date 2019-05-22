defmodule Telepath.Torrent do
  alias Kaur.Result
  alias Telepath.Data.Seedbox

  def list() do
    get_torrents = fn pid ->
      fn -> GenServer.call(pid, :get_torrents) end
    end

    get_torrents
    |> Seedbox.dispatch_call()
    |> Result.map(&List.flatten/1)
  end
end
