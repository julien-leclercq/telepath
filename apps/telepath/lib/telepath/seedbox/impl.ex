defmodule Telepath.Seedbox.Impl do
  @moduledoc """
  The concrete implementation of actions on a seedbox worker state
  """
  alias Kaur.Result
  alias Telepath.Data.Seedbox
  alias Telepath.Seedbox.Auth

  import Ecto.Changeset

  require Logger

  def create(params) do
    %Seedbox{}
    |> Seedbox.changeset(params)
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

    handle_session_success = fn session ->
      Logger.info(fn -> "[telepath] session success" end)

      changeset
      |> put_change(:accessible, true)
      |> put_change(:session, session)
    end

    box
    |> Transmission.get_session()
    |> Result.either(
      fn reason ->
        case reason do
          {:conflict, session_id} ->
            box_with_session = put_change(changeset, :session_id, session_id)

            box_with_session
            |> apply_changes
            |> Transmission.get_session()
            |> Result.either(
              fn reason ->
                add_error(changeset, :session, "#{reason}")
              end,
              fn session ->
                session
                |> handle_session_success.()
                |> put_change(:session_id, session_id)
              end
            )

          _ ->
            put_change(changeset, :accessible, false)
        end
      end,
      handle_session_success
    )
  end

  def put_torrents(%{valid?: false} = changeset), do: changeset

  def put_torrents(changeset) do
    get_all_torrents_if_accessible = fn seedbox ->
      if seedbox.accessible do
        Transmission.get_all_torrents(seedbox)
      else
        Result.error(:box_not_accessible)
      end
    end

    add_torrents_to_box = fn torrents -> put_change(changeset, :torrents, torrents) end

    put_error = fn reason ->
      Logger.info(fn -> "[telepath] could not get torrent for #{reason}" end)

      changeset
      |> add_error(:torrents, "#{reason}")
    end

    changeset
    |> apply_changes
    |> get_all_torrents_if_accessible.()
    |> Result.either(
      fn reason ->
        case reason do
          {:conflict, session_id} ->
            box_with_session = put_change(changeset, :session_id, session_id)

            box_with_session
            |> apply_changes
            |> get_all_torrents_if_accessible.()
            |> Result.either(put_error, fn torrents ->
              torrents
              |> add_torrents_to_box.()
              |> put_change(:session_id, session_id)
            end)

          _ ->
            put_error.(reason)
        end
      end,
      fn torrents ->
        add_torrents_to_box.(torrents)
      end
    )
  end

  def update(seedbox, params) do
    seedbox
    |> Seedbox.changeset(params)
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

  def get_torrents(%Seedbox{accessible: true} = seedbox) do
    seedbox
    |> Map.get(:torrents)
    |> Enum.map(&Map.put(&1, :seedbox_id, seedbox.id))
    |> Result.ok()
  end

  def get_torrents(_seedbox) do
    Result.error("seedbox is unavailable")
  end
end
