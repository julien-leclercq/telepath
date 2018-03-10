defmodule Transmission do
  @moduledoc """
  Documentation for Transmission.
  """

  defmodule Request do
    @moduledoc """
    Provides a data structure for Transmission api requests
    """

    @derive Poison.Encoder
    defstruct [:tag, :method, :arguments]
  end

  defmodule Response do
    @moduledoc """
    Provides a data structure for Transmission api responses
    """

    @derive Poison.Encoder
    defstruct [:tag, :result, :arguments]
  end
end
