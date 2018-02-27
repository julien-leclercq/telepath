module Types exposing (..)

import Data.Torrent exposing (Torrent)
import Navigation exposing (Location)


type alias Model =
    List Torrent


type Message
    = None
    | AddTorrent
    | UrlChange Location


type Route
    = TorrentList
    | Settings
