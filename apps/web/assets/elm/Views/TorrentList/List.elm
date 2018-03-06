module Views.TorrentList.List exposing (..)

import Data.Torrent exposing (Torrent)
import Html exposing (Html, div, text)
import Html.Attributes as Attrs
import Html.Events exposing (onClick)
import Views.TorrentList.Item as Item
import Pages.Torrents as TorrentsPage


listHeader : Html TorrentsPage.Msg
listHeader =
    div [ Attrs.class "level columns" ]
        [ div [ Attrs.class "level-left column" ]
            [ div [ Attrs.class "button", onClick TorrentsPage.AddTorrent ] [ text "Add torrent" ]
            ]
        ]


view : List Torrent -> Html TorrentsPage.Msg
view torrents =
    div [ Attrs.class "column" ] (listHeader :: (List.map Item.view torrents))
