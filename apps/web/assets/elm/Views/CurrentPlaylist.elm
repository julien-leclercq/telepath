module Views.CurrentPlaylist exposing (view)

import Data.Track exposing (Track)
import Html exposing (Html, text)
import Utils.Playlist exposing (Playlist)


view : Playlist Track -> Html msg
view _ =
    text ""
