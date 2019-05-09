defmodule Web.Track do
  alias Kaur.Result
  alias Koop.Schema.Track

  def list(_params) do
    DB.Repo.all(Track)
    |> Result.ok()
  end

  def get_path(track_id) do
    track =
      Track
      |> DB.Repo.get(track_id)

    track.filename
  end
end
