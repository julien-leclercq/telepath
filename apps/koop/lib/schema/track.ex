defmodule Koop.Schema.Track do
  use Ecto.Schema

  import Ecto.Changeset

  alias Kaur.Result

  alias DB.Repo

  schema "tracks" do
    field(:title, :string)
    field(:track, :string)
    field(:artist, :string)
    field(:filename, :string)
    field(:album, :string)
    field(:duration, :float)
  end

  @required_params [:filename]
  @non_required_params [:title, :track, :artist, :album, :duration]

  def changeset(struct \\ %__MODULE__{}, params) do
    struct
    |> cast(params, @non_required_params ++ @required_params)
    |> validate_required(@required_params)
  end

  def fully_tagged?(track) do
    track =
      case track do
        %Ecto.Changeset{} -> apply_changes(track)
        _ -> track
      end

    is_value? = fn key ->
      Map.get(track, key)
      |> is_nil
      |> (&(!&1)).()
    end

    Enum.all?(@non_required_params, is_value?)
  end

  # ---- Queries ----
  def get_or_create(%Ecto.Changeset{} = track) do
    {_, filename} = fetch_field(track, :filename)

    __MODULE__
    |> Repo.get_by(filename: filename)
    |> Result.from_value()
    |> Result.or_else(fn _ ->
      Repo.insert(track)
    end)
  end

  def update_or_create(%Ecto.Changeset{} = changeset) do
    {_, filename} = fetch_field(changeset, :filename)

    __MODULE__
    |> Repo.get_by(filename: filename)
    |> Result.from_value
    |> Result.either(
      fn _ ->
        Repo.insert(changeset)
      end,
      fn track ->
        track
        |> change(changeset.changes)
        |> Repo.update
      end
    )
  end
end
