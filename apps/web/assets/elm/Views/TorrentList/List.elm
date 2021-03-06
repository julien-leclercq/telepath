module Views.TorrentList.List exposing (listHeader, view)

import Data.Torrent exposing (Torrent)
import Html exposing (Html, div, text)
import Html.Attributes as Attrs
import Html.Events exposing (onClick)
import Pages.Torrents as TorrentsPage
import Views.TorrentList.Item as Item


listHeader : Html TorrentsPage.Msg
listHeader =
    div [ Attrs.class "level columns" ]
        [ div [ Attrs.class "level-left column" ]
            [ div [ Attrs.class "button", onClick TorrentsPage.AddTorrent ] [ text "Add torrent" ]
            ]
        , div [ Attrs.class "level-left column" ]
            [ div [ Attrs.class "button", onClick (TorrentsPage.Sort TorrentsPage.Name) ] [ text "Sort by name" ] ]
        ]


view : List Torrent -> Html TorrentsPage.Msg
view torrents =
    div [ Attrs.class "column" ] (listHeader :: List.map Item.view torrents)
