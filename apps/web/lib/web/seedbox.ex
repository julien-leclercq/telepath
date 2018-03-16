defmodule Web.Seedbox do
  @moduledoc """
  This module provide functions to access and treat seedbox informations
  """

  def list do
    {:ok,
     [
       #  %{
       #    id: 1,
       #    url: "seedbox url",
       #    port: 3454,
       #    remote: true
       #  }
     ]}
  end

  def create(params) do
    Telepath.Seedbox.create(params)
  end
end
