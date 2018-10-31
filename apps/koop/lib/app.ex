defmodule Koop.App do
  use Application

  def start(_,_), do: Supervisor.start_link([], strategy: :one_for_one)
end
