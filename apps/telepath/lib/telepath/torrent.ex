defmodule Telepath.Torrent do
  alias Kaur.Result
  alias Telepath.Seedbox

  def list() do
    get_torrents = fn pid ->
      fn -> GenServer.call(pid, :get_torrents) end
    end

    Seedbox.dispatch_call(get_torrents)
    |> Result.map(&List.flatten/1)
  end
end
