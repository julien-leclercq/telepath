defmodule Koop.LibraryTest do
  use ExUnit.Case

  # Dependency alias
  alias ResponseSnapshot, as: Snap

  # Internal aliases
  alias Koop.Library

  describe "get_track_infos" do
    test "it match die brucke snapshot" do
      {:ok, infos} =
        "test/support/panda_dub_die_brucke.flac"
        |> Library.get_track_infos()

      Snap.store_and_compare!(infos, path: "test/library/die_brucke.json")
    end
  end
end
