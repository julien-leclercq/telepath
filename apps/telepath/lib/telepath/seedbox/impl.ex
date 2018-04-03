defmodule Telepath.Seedbox.Impl do
  @moduledoc """
  The concrete implementation of actions on a seedbox worker state
  """
  alias Ecto.Changeset
  alias Kaur.Result
  alias Telepath.Seedbox
  alias Telepath.Seedbox.Auth
  import Changeset
  require Logger

  @max_port :math.pow(2, 16) - 1
  @min_port 0
  @params [:host, :id, :name, :port]
  @required_params [:host, :port]

  @spec changeset(%Seedbox{}, map) :: Ecto.Changeset.t()
  def changeset(%Seedbox{} = seedbox, params) do
    seedbox
    |> cast(params, @params)
    |> validate_required(@required_params)
    |> validate_number(:port, greater_than: @min_port)
    |> validate_number(:port, less_than: @max_port)
    |> cast_embed(:auth, with: &auth_changeset/2)
    |> put_session
    |> put_torrents
  end

  def create(params) do
    %Seedbox{}
    |> changeset(params)
    |> case do
      %{valid?: true} = changeset ->
        changeset
        |> put_change(:id, Ecto.UUID.generate())
        |> apply_changes
        |> Result.ok()

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

  def put_session(%{valid?: false} = changeset), do: changeset

  def put_session(changeset) do
    %{host: _host, port: _port} = box = apply_changes(changeset)

    case Transmission.get_session(box) do
      {:ok, session} ->
        Logger.info(fn -> "[telepath] session success" end)

        changeset
        |> put_change(:accessible, true)
        |> put_change(:session, session)

      {:error, _reason} ->
        put_change(changeset, :accessible, false)
    end
  end

  def put_torrents(seedbox) do
    get_all_torrents_if_accessible = fn seedbox ->
      if seedbox.accessible do
        Transmission.get_all_torrents(seedbox)
      else
        Result.error(:box_not_accessible)
      end
    end

    case seedbox do
      %Seedbox{} ->
        seedbox
        |> get_all_torrents_if_accessible.()
        |> Result.either(
          fn reason ->
            Logger.info(fn -> "[telepath] could not get torrent for #{reason}" end)
            Result.error(reason)
          end,
          fn torrents ->
            seedbox
            |> put_change(:torrents, torrents)
            |> apply_changes
            |> Result.ok()
          end
        )

      %Changeset{} ->
        seedbox
        |> apply_changes
        |> get_all_torrents_if_accessible.()
        |> Result.either(
          fn reason ->
            Logger.info(fn -> "[telepath] could not get torrent for #{reason}" end)
          end,
          fn torrents ->
            seedbox
            |> put_change(:torrents, torrents)
          end
        )
    end
  end

  def auth_changeset(auth \\ %Auth{}, params) do
    auth
    |> cast(params, [:username, :password])
  end

  def update(seedbox, params) do
    seedbox
    |> changeset(params)
    |> case do
      %{valid?: true} = changeset ->
        changeset
        |> apply_changes
        |> Result.ok()

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

  def refresh(%Seedbox{} = seedbox) do
    seedbox
    |> change
    |> put_session
    |> put_torrents
    |> apply_changes
  end
end
