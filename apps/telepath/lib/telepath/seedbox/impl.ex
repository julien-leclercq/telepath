defmodule Telepath.Seedbox.Impl do
  @moduledoc """
  The concrete implementation of actions on a seedbox worker state
  """
  alias Kaur.Result
  alias Telepath.Seedbox
  alias Telepath.Seedbox.Auth
  import Ecto.Changeset

  @max_port :math.pow(2, 16) - 1
  @min_port 0
  @params [:host, :id, :name, :port]
  @required_params [:host, :port]

  def create(params) do
    %Seedbox{}
    |> cast(params, @params)
    |> validate_required(@required_params)
    |> validate_number(:port, greater_than: @min_port)
    |> validate_number(:port, less_than: @max_port)
    |> put_session
    |> put_change(:id, Ecto.UUID.generate())
    |> cast_embed(:auth, with: &auth_changeset/2)
    |> case do
      %{valid?: true} = changeset ->
        Result.ok(apply_changes(changeset))

      changeset ->
        changeset
        |> traverse_errors(fn {msg, opts} ->
          Enum.reduce(opts, msg, fn {key, value}, acc ->
            String.replace(acc, "%{#{key}}", to_string(value))
          end)
        end)
        |> Result.error()
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

  def auth_changeset(auth \\ %Auth{}, params) do
    auth
    |> cast(params, [:username, :password])
  end
end
