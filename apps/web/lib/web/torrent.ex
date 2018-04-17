defmodule Web.Torrent do
  @moduledoc """
  This module provides function to retrieve and treat data about torrents.
  """
  def list do
    Telepath.Torrent.list()
  end
end
