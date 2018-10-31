defmodule Web.Seedbox do
  @moduledoc """
  This module provide functions to access and treat seedbox informations
  """

  def list do
    Telepath.Seedbox.list()
  end

  def create(params) do
    Telepath.Seedbox.create(params)
  end

  def update(id, params) do
    Telepath.Seedbox.update(id, params)
  end

  def delete(id) do
    Telepath.Seedbox.delete(id)
  end
end
