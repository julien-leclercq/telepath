defmodule DB.Repo.Migrations.CreateLibraries do
  use Ecto.Migration

  def change do
    create table :libraries do
      add :root_path, :string, unique: true
    end
  end
end
