defmodule DB.Repo.Migrations.AddManuallyEditedToTrack do
  use Ecto.Migration

  def change do
    alter table :tracks do
      add :manually_edited, :boolean, default: false
    end
  end
end
