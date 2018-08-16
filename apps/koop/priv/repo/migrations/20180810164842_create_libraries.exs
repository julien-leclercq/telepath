defmodule Koop.Repo.Migrations.CreateLibraries do
  use Ecto.Migration

  def change do
    create table :libraries do
      add :root_path, :string
    end
  end
end
