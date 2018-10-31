defmodule WebWeb.Api.TorrentController do
  alias Kaur.Result
  use WebWeb, :controller

  def index(conn, _params) do
    Web.Torrent.list()
    |> Result.either(
      fn reason ->
        conn
        |> put_status(500)
        |> json(%{error: reason})
      end,
      fn torrents ->
        json(conn, %{torrents: torrents})
      end
    )
  end
end
