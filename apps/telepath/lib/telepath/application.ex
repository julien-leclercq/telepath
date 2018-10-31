defmodule Telepath.Application do
  @moduledoc """
  Implementation of Telepath application
  """
  alias Telepath.Seedbox
  use Application

  def start(_type, _args) do
    children = [
      %{
        id: Seedbox.Repository,
        start: {Seedbox.Repository, :start_link, []},
        type: :supervisor
      }
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
