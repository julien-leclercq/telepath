defmodule DB.Repo.Migrations.AddDurationToTracks do
  use Ecto.Migration

  def change do
    alter table :tracks do
      add :duration, :float
    end
  end
end
