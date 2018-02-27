module TorrentList.List exposing (..)

import Data.Torrent exposing (Torrent)
import Html exposing (Html, div, text)
import Html.Attributes as Attrs
import Html.Events exposing (onClick)
import TorrentList.Item as Item
import Types exposing (..)


listHeader : Html Message
listHeader =
    div [ Attrs.class "level columns" ]
        [ div [ Attrs.class "level-left column" ]
            [ div [ Attrs.class "button", onClick AddTorrent ] [ text "Add torrent" ]
            ]
        ]


view : List Torrent -> Html Message
view torrents =
    div [ Attrs.class "column" ] (listHeader :: (List.map Item.view torrents))
