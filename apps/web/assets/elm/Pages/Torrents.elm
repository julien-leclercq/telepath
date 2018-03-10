module Pages.Torrents exposing (..)

import Data.Torrent exposing (..)
import Http
import Request.Torrent as Request


type Msg
    = AddTorrent


type alias Model =
    List Torrent


init : Cmd (Result Http.Error (List Torrent))
init =
    Request.list
        |> Http.send identity
