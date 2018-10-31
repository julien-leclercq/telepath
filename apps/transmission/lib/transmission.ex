defmodule Transmission do
  alias Kaur.Result
  require Logger
  use HTTPoison.Base

  @get_session "session-get"
  @get_torrents "torrent-get"
  @session_id_key "X-Transmission-Session-Id"
  @torrent_fields [
    "activityDate",
    "addedDate",
    "bandwidthPriority",
    "comment",
    "corruptEver",
    "creator",
    "dateCreated",
    "desiredAvailable",
    "doneDate",
    "downloadDir",
    "downloadedEver",
    "downloadLimit",
    "downloadLimited",
    "error",
    "errorString",
    "eta",
    "etaIdle",
    "files",
    "fileStats",
    "hashString",
    "haveUnchecked",
    "haveValid",
    "honorsSessionLimits",
    "id",
    "isFinished",
    "isPrivate",
    "isStalled",
    "leftUntilDone",
    "magnetLink",
    "manualAnnounceTime",
    "maxConnectedPeers",
    "metadataPercentComplete",
    "name",
    "peer",
    "peers",
    "peersConnected",
    "peersFrom",
    "peersGettingFromUs",
    "peersSendingToUs",
    "percentDone",
    "pieces",
    "pieceCount",
    "pieceSize",
    "priorities",
    "queuePosition",
    "rateDownload",
    "rateUpload",
    "recheckProgress",
    "secondsDownloading",
    "secondsSeeding",
    "seedIdleLimit",
    "seedIdleMode",
    "seedRatioLimit",
    "seedRatioMode",
    "sizeWhenDone",
    "startDate",
    "status",
    "trackers",
    "trackerStats",
    "totalSize",
    "torrentFile",
    "uploadedEver",
    "uploadLimit",
    "uploadLimited",
    "uploadRatio",
    "wanted",
    "webseeds",
    "webseedsSendingToUs"
  ]

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
  end

  def get_all_torrents(seedbox, options \\ []) do
    %Request{
      method: @get_torrents,
      arguments: %{
        fields: @torrent_fields
      }
    }
    |> send_request(seedbox, [], options)
    |> Result.map(&Map.get(&1, "torrents"))
  end

  defp send_request(
         %Request{} = request,
         %{auth: %{username: user, password: password}} = seedbox,
         headers,
         options
       ) do
    IO.puts("authentified seedbox")
    seedbox = Map.delete(seedbox, :auth)
    options = [hackney: [basic_auth: {user, password}]] ++ options

    request
    |> send_request(seedbox, headers, options)
  end

  defp send_request(%Request{} = request, %{host: _host, port: _port} = seedbox, headers, options) do
    log_request(seedbox, request)

    headers =
      if seedbox.session_id do
        [seedbox.session_id | headers]
      else
        headers
      end

    seedbox
    |> build_url
    |> post(request, headers, options)
    |> Result.and_then(&handle_response/1)
  end

  defp log_request(%{host: host, port: port} = _seedbox, %{method: method} = _request) do
    Logger.info(fn -> "[transmission] sending #{method} to #{host}:#{port}" end)
  end

  defp process_request_body(request) do
    Poison.encode!(request)
  end

  defp process_request_options(options) do
    options = [follow_redirect: true] ++ options
    proxy = Application.get_env(Transmission, :proxy)

    if proxy && String.length(proxy) > 0 do
      Keyword.merge(options, [hackney: [proxy: proxy]], fn key, v1, v2 ->
        case key do
          :hackney ->
            Keyword.merge(v1, v2)

          _ ->
            v1
        end
      end)
    else
      options
    end
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
      %Response{result: "success"} = response -> {:ok, response.arguments}
      %Response{result: reason} -> {:error, reason}
    end)
  end

  defp find_transmission_header(response) do
    response.headers
    |> Enum.find(fn {key, _} -> key == @session_id_key end)
  end
end
