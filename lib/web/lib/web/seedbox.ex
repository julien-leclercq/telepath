defmodule Web.Seedbox do
  @moduledoc """
  This module provide functions to access and treat seedbox informations
  """
  alias Telepath.Data.Seedbox

  def list do
    Seedbox.list()
  end

  def create(params) do
    Seedbox.create(params)
  end

  def update(id, params) do
    Seedbox.update(id, params)
  end

  def delete(id) do
    Seedbox.delete(id)
  end
end
