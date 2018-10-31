defmodule WebWeb.Api.SeedboxView do
  use WebWeb, :view

  def render("show.json", %{seedbox: seedbox}) do
    %{seedbox: render_one(seedbox, __MODULE__, "seedbox.json")}
  end

  def render("index.json", %{seedboxes: seedboxes}) do
    %{seedboxes: render_many(seedboxes, __MODULE__, "seedbox.json")}
  end

  def render("seedbox.json", %{seedbox: seedbox}) do
    seedbox
    |> Map.delete(:session_id)
  end
end
