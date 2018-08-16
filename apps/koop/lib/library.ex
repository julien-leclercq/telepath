defmodule Koop.Library do
  alias Kaur.Result

  require Logger

  defstruct files: []

  @doc """
  add the given path to the library
  """
  @spec get_infos(Path.t()) :: Result.result_tuple()
  def get_infos(path) do
    Logger.debug "Starting getting infos on #{path}"

    path
    |> File.exists?()
    |> unless do
      {:error, "path does not exists"}
    else
      if File.dir?(path) do
        path
        |> File.ls()
        |> Result.and_then(fn files ->
          Enum.map(files, &get_infos("#{path}/#{&1}")
          )
        end)
      else
        ext = Path.extname(path)

        cond do
          ext == ".mp3" || ext == ".flac" -> get_track_infos(path)
          true -> {:ok, :not_audio_file}
        end
      end
    end
  end

  @spec get_track_infos(Path.t()) :: Map.t()
  def get_track_infos(path) do
    ffprobe_description =
      path
      |> FFprobe.format()

    tags =
      ffprobe_description["tags"]
      |> Enum.map(fn {key, value} ->
        {String.downcase(key), value}
      end)
      |> Map.new()

    ffprobe_description
    |> Map.delete("tags")
    |> Map.merge(tags)
  end
end
