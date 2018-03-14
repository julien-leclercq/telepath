defmodule WebWeb.Api.SeedboxController do
  use WebWeb, :controller

  def index(conn, _params) do
    case Web.Seedbox.list() do
      {:ok, seedboxes} -> json(conn, %{seedboxes: seedboxes})
      {:error, reason} -> json(conn, %{error: reason})
    end
  end

  def create(conn, %{"seedbox" => seedbox_params} = _params) do
    case Web.Seedbox.create(seedbox_params) do
      {:ok, seedbox} -> json(conn, %{seedbox: seedbox})
      {:error, reason} -> json(conn, %{error: reason})
    end
  end
end
