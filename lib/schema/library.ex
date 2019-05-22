defmodule Koop.Schema.Library do
  use Ecto.Schema

  schema "libraries" do
    field(:root_path, :string)
  end
end
