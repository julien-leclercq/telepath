defmodule Transmission do
  @moduledoc """
  Documentation for Transmission.
  """

  defmodule Request do
    @derive Poison.Encoder
    defstruct [:tag, :method, :arguments]
  end

  defmodule Response do
    @derive Poison.Encoder
    defstruct [:tag, :result, :arguments]
  end
end
