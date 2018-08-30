defmodule WebWeb.Api.TrackController do
  use WebWeb, :controller

  alias Kaur.Result

  def index(conn, params) do
    Web.Track.list(params)
    |> Result.either(
      fn reason -> json(conn, %{error: reason}) end,
      fn tracks ->
        render(conn, "index.json", tracks: tracks)
      end
    )
  end
end
