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
  end

  @required_params [:filename]
  @non_required_params [:title, :track, :artist, :album]

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
end
