defmodule WebWeb.Api.TrackView do
  use WebWeb, :view

  def render("show.json", %{track: track}) do
    %{track: render_one(track, __MODULE__, "track.json")}
  end

  def render("index.json", %{tracks: tracks}) do
    %{tracks: render_many(tracks, __MODULE__, "track.json")}
  end

  def render("track.json", %{track: track}) do
    %{
      album: track.album,
      artist: track.artist,
      duration: track.duration,
      title: track.title,
      id: track.id,
      path: track.filename
    }
  end
end
