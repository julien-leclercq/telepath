defmodule Koop.Repo.Migrations.CreateTracks do
  use Ecto.Migration

  def change do
    create table :tracks do
      add :title, :string
      add :track, :string
      add :artist, :string
      add :album, :string
      add :filename, :string, unique: true
    end
  end
end
