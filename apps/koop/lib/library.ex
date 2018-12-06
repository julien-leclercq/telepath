defmodule Koop.Library do

  @spec create_library(Path.t()) :: :ok
  def create_library(root_path) do
    Library.InfosFetcher.Dispatcher.add_path(root_path)
  end
end
