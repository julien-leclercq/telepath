defmodule Koop.Library do
  alias Kaur.Result

  alias Koop.Repo
  alias Koop.Schema.Track

  require Logger

  @supported_formats [".mp3", ".flac"]

  @spec create_library(Path.t()) :: Result.result_tuple()
  def create_library(root_path) do
    root_path
    |> get_infos()
    |> Enum.map(
      &Result.and_then(&1, fn cs ->
        Track.update_or_create(cs)
      end)
    )
  end

  @doc """
  add the given path to the library
  """
  @spec get_infos(Path.t()) :: Result.result_tuple()
  def get_infos(path) do
    Logger.debug("Starting getting infos on #{path}")

    path
    |> File.exists?()
    |> unless do
      Result.error(:unknown_path)
    else
      if File.dir?(path) do
        path
        |> File.ls()
        |> Result.and_then(fn files ->
          Enum.map(
            files,
            &get_infos("#{path}/#{&1}")
          )
        end)
        |> List.flatten()
      else
        get_track_infos(path)
        |> Result.tap(fn cs ->
          Track.fully_tagged?(cs)
          |> unless do
            Logger.warn("#{path} is not fully tagged")
          end
        end)
      end
    end
  end

  def get_infos_with_dive_in_fs(path) do
    log_debug = fn path ->
      Logger.debug("Starting getting infos on #{path}")
    end

    action = fn path ->
      get_track_infos(path)
      # |> Result.tap(fn cs ->
      #   Track.fully_tagged?(cs)
      #   |> unless do
      #     Logger.warn("#{path} is not fully tagged")
      #   end
      # end)
    end

    dive_in_fs(path, action, before_action: log_debug)
  end

  @spec get_track_infos(Path.t()) :: Map.t()
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

  defp dive_in_fs(path, action, opts \\ []) do
    before_action = Keyword.get(opts, :before_action, & &1)

    before_action.(path)

    recursive_call = fn sub_path ->
      path
      |> Path.join(sub_path)
      |> dive_in_fs(action, opts)
    end

    path
    |> File.exists?()
    |> unless do
      {:error, :unknown_path}
    else
      if File.dir?(path) do
        path
        |> File.ls()
        |> Result.and_then(&Enum.map(&1, recursive_call))
        |> List.flatten()
      else
        action.(path)
      end
    end
  end
end
