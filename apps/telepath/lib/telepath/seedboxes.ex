defmodule Telepath.Seedboxes do
  alias Kaur.Result

  alias Telepath.Data.Seedbox
  alias Telepath.Repo

  @spec create_seedbox(%{}) :: {:ok, %Seedbox{}} | {:error, Ecto.CHangeset.t()}
  def create_seedbox(params) do
    %Seedbox{}
    |> Seedbox.changeset(params)
    |> Repo.insert()
    |> Result.map_error(fn changeset ->
      treat_error = fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end

      Ecto.Changeset.traverse_errors(changeset, treat_error)
    end)
  end
end
