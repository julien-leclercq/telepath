defmodule Telepath.Seedbox.Auth do
  use Ecto.Schema

  @primary_key false

  embedded_schema do
    field :username, :string
    field :password, :string
  end

end
