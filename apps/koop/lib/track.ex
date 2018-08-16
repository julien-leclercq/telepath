defmodule Koop.Track do
  @moduledoc """
    Track metadata manipulation
  """

  defstruct [
    :album,
    :artist,
    :title,
    :duration,
    :track,
    :versions
  ]
end
