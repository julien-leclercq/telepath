module Pages.Torrents exposing (..)

import Data.Torrent exposing (..)


type Msg
    = AddTorrent


type alias Model =
    List Torrent
