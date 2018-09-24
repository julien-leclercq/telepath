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
end
