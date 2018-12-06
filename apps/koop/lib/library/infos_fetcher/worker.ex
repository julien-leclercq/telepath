defmodule Library.InfosFetcher.Worker do
  require Logger

  alias Kaur.Result
  alias Koop.Schema.Track

  @supported_formats [".mp3", ".flac"]

  def fetch_infos(path) do
    res =
      path
      |> File.exists?()
      |> unless do
        Result.error(:unkwown_path)
      else
        if File.dir?(path) do
          path
          |> File.ls()
          # Do not treat hidden files
          |> Result.map(fn files ->
            Enum.filter(files, fn filename ->
              case filename do
                "." <> _hidden_name -> false
                _name -> true
              end
            end)
          end)
          |> Result.map(fn children -> {:dir, children} end)
        else
          path
          |> get_track_infos()
          |> Result.ok()
        end
      end

    :ok =
      GenServer.cast(
        Library.InfosFetcher.Dispatcher,
        {:infos_fetched, {path, res}}
      )
  end

  @spec get_track_infos(Path.t()) :: Reuslt.result_tuple()
  def get_track_infos(path) do
    unless Path.extname(path) in @supported_formats do
      Result.error({:unknown_format, path})
    else
      ffprobe_description =
        path
        |> FFprobe.format()

      ffprobe_description["tags"]
      # Error case if description does not contains tags
      |> Result.from_value()
      |> Result.either(
        fn _ ->
          # if error then doesn't treat tags
          ffprobe_description
        end,
        fn tags ->
          downcased_tags =
            Enum.map(tags, fn {key, value} ->
              {String.downcase(key), value}
            end)
            |> Map.new()

          ffprobe_description
          |> Map.delete("tags")
          |> Map.merge(downcased_tags)
        end
      )
      |> Track.changeset()
      |> Result.ok()
    end
  end
end
