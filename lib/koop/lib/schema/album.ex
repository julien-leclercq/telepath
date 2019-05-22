defmodule Koop.Schema.Album do
  use Ecto.Schema

  schema "albums" do
    field(:title, :string)

    has_many(:versions, __MODULE__.Version)
  end

  defmodule Version do
    use Ecto.Schema

    schema "album_versions" do
      field(:path, :string)
      field(:quality, :string)
      belongs_to(:album, Koop.Schema.Album)
    end
  end
end
