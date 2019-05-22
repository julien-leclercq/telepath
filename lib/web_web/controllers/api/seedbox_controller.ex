defmodule WebWeb.Api.SeedboxController do
  alias Kaur.Result
  use WebWeb, :controller

  def index(conn, _params) do
    Web.Seedbox.list()
    |> Result.either(fn reason -> json(conn, %{error: reason}) end, fn seedboxes ->
      render(conn, "index.json", seedboxes: seedboxes)
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
        render(conn, "show.json", seedbox: seedbox)
      end
    )
  end

  def update(conn, %{"seedbox" => seedbox_params, "id" => id} = _params) do
    id
    |> Web.Seedbox.update(seedbox_params)
    |> Result.either(
      fn reason ->
        case reason do
          :not_found -> conn |> put_status(:not_found)
          _ -> conn |> put_status(:unprocessable_entity)
        end
        |> json(%{error: reason})
      end,
      fn seedbox ->
        render(conn, "show.json", seedbox: seedbox)
      end
    )
  end

  def delete(conn, %{"id" => id} = _params) do
    id
    |> Web.Seedbox.delete()
    |> Result.either(
      fn reason ->
        case reason do
          :not_found -> conn |> put_status(:not_found)
          _ -> conn |> put_status(:unprocessable_entity)
        end
        |> json(%{errors: reason})
      end,
      fn _ ->
        send_resp(conn, :ok, id)
      end
    )
  end
end
