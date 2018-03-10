defmodule WebWeb.Api.TorrentController do
  use WebWeb, :controller

  def index(conn, _params) do
    case Web.Torrent.list() do
      {:ok, torrents} -> json(conn, %{torrents: torrents})
      {:error, reason} -> json(conn, %{error: reason})
    end
  end
end
