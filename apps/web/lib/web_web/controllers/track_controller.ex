defmodule WebWeb.Api.TrackController do
  use WebWeb, :controller

  alias Kaur.Result

  def index(conn, params) do
    tracks = Web.Track.list(params)

    tracks
    |> Result.either(
      fn reason -> json(conn, %{error: reason}) end,
      fn tracks ->
        render(conn, "index.json", tracks: tracks)
      end
    )
  end

  def get_file(conn, _params = %{"track_id" => track_id}) do
    track = Web.Track.get_path(track_id)

    conn
    |> send_file(200, "/#{track}")
  end
end
