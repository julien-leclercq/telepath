defmodule Web.Track do
  alias Kaur.Result

  def list(_params) do
    Koop.Repo.all(Koop.Schema.Track)
    |> Result.ok()
  end
end
