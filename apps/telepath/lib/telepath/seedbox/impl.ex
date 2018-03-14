defmodule Telepath.Seedbox.Impl do
  @moduledoc """
  The concrete implementation of actions on a seedbox worker state
  """
  alias Kaur.Result
  alias Telepath.Seedbox
  import Ecto.Changeset

  @params [:host, :id, :name, :port]
  @required_params [:host, :port]

  def create(params) do
    %Seedbox{}
    |> cast(params, @params)
    |> validate_required(@required_params)
    |> put_session
    |> put_change(:id, Ecto.UUID.generate())
    |> case do
      %{valid?: true} = changeset -> Result.ok(apply_changes(changeset))
      changeset -> Result.error(changeset.errors)
    end
  end

  def put_session(changeset) do
    %{host: _host, port: _port} =
      box =
      changeset.data
      |> Map.merge(changeset.changes)

    case Transmission.get_session(box) do
      {:ok, session} ->
        changeset
        |> put_change(:accessible, true)
        |> put_change(:session, session)

      {:error, _reason} ->
        put_change(changeset, :accessible, false)
    end
  end
end
