module Views.CurrentPlaylist exposing (view)

import Data.Track exposing (Track)
import Html exposing (Html, div, text)
import Utils.Playlist exposing (Playlist)


view : Playlist Track -> Html msg
view playlist =
    div [] []
