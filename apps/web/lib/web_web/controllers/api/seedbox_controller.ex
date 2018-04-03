defmodule WebWeb.Api.SeedboxController do
  alias Kaur.Result
  use WebWeb, :controller

  def index(conn, _params) do
    Web.Seedbox.list()
    |> Result.either(fn reason -> json(conn, %{error: reason}) end, fn seedboxes ->
      json(conn, %{seedboxes: seedboxes})
    end)
  end

  def create(conn, %{"seedbox" => seedbox_params} = _params) do
    seedbox_params
    |> Web.Seedbox.create()
    |> Result.either(
      fn reason ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
      end,
      fn seedbox ->
        json(conn, %{seedbox: seedbox})
      end
    )
  end
end
