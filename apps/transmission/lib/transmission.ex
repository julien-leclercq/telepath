defmodule Transmission do
  alias Kaur.Result
  use HTTPoison.Base

  @get_session "session-get"
  @session_id_key "X-Transmission-Session-Id"

  @moduledoc """
  Documentation for Transmission.
  """

  defmodule Request do
    @moduledoc """
    Provides a data structure for Transmission api requests
    """

    defstruct [:method, arguments: []]
  end

  defmodule Response do
    @moduledoc """
    Provides a data structure for Transmission api responses
    """

    defstruct [:result, :arguments]
  end

  def get_session(%{host: _host, port: _port} = seedbox, options \\ []) do
    %Request{
      method: @get_session
    }
    |> send_request(seedbox, [], options)
    |> Result.and_then(&handle_response/1)
  end

  defp send_request(
         %Request{} = request,
         %{auth: %{user: user, password: password}} = seedbox,
         headers,
         options
       ) do
    seedbox = Map.delete(seedbox, :auth)
    options = [hackney: [basic_auth: {user, password}]] ++ options

    request
    |> send_request(seedbox, headers, options)
    |> Result.and_then(&handle_response/1)
    |> Result.or_else(fn {:conflict, header} ->
      send_request(request, seedbox, [header | headers], options)
    end)
  end

  defp send_request(%Request{} = request, %{host: _host, port: _port} = seedbox, headers, options) do
    seedbox
    |> build_url
    |> post(request, headers, options)
  end

  defp process_request_body(request) do
    Poison.encode!(request)
  end

  defp process_request_options(options) do
    [follow_redirect: true] ++ options
  end

  defp process_url(url) do
    "#{url}/transmission/rpc"
  end

  defp build_url(%{host: host, port: port}) do
    "#{host}:#{port}"
  end

  defp handle_response(%HTTPoison.Response{status_code: status_code} = response)
       when status_code >= 400 do
    case status_code do
      401 ->
        Result.error(:unauthorized)

      500 ->
        Result.error(:fatal_error)

      409 ->
        Result.error({:conflict, find_transmission_header(response)})

      _ ->
        Result.error(status_code)
    end
  end

  defp handle_response(%HTTPoison.Response{body: body}) do
    body
    |> Poison.decode(as: %Response{})
    |> Result.and_then(fn
      %Response{result: "success"} = response -> {:ok, response}
      %Response{result: reason} -> {:error, reason}
    end)
  end

  defp find_transmission_header(response) do
    response.headers
    |> Enum.find(fn {key, _} -> key == @session_id_key end)
  end
end
