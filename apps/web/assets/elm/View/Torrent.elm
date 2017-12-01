module View.Torrent exposing (torrentView, torrentsView)

import Data.Torrent exposing (Torrent)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Types exposing (Message)


torrentView : Torrent -> Html Message
torrentView torrent =
    div [ class "box" ]
        [ text torrent.name
        ]

fileView

torrentsView : List Torrent -> Html Message
torrentsView torrents =
    div [ class "column" ] (List.map torrentView torrents)
