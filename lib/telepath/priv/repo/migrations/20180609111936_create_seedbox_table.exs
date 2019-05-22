defmodule Telepath.Repo.Migrations.CreateSeedboxTable do
  use Ecto.Migration

  def change do
    create table :seedboxes do
      add :host, :string
      add :name, :string
      add :port, :integer
      add :remote, :boolean, default: true
    end
  end
end
