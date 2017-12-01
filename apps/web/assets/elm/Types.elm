module Types exposing (Message, Model)

import Data.Torrent exposing (Torrent)


type alias Model =
    List Torrent


type Message
    = None
