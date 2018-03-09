defmodule Transmission do
  @moduledoc """
  Documentation for Transmission.
  """

  defmodule Request do
    defstruct [:method, :arguments]
  end

  defmodule Response do
    defstruct [:result, :arguments]
  end

end
