defmodule Koop.Library do
  alias Kaur.Result

  defstruct files: []

  @doc """
  add the given path to the library
  """
  @spec get_infos(Path.t()) :: Result.result_tuple()
  def get_infos(path) do
    path
    |> File.exists?()
    |> unless do
      {:error, "path does not exists"}
    else
      if File.dir?(path) do
        path
        |> File.ls()
        |> Enum.map(&get_track_infos(&1))
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