module Routes exposing (..)

import Html
import Html.Attributes as Attrs
import Navigation exposing (Location)
import UrlParser as Url


type Route
    = TorrentList
    | Settings
    | TrackList


fromLocation : Location -> Maybe Route
fromLocation =
    Url.parseHash route


route : Url.Parser (Route -> a) a
route =
    Url.oneOf
        [ Url.map TorrentList Url.top
        , Url.map TorrentList (Url.s "torrents")
        , Url.map Settings (Url.s "settings")
        , Url.map TrackList (Url.s "tracks")
        ]


toString : Route -> String
toString route =
    let
        pieces =
            case route of
                TorrentList ->
                    [ "torrents" ]

                Settings ->
                    [ "settings" ]

                TrackList ->
                    [ "tracks" ]
    in
        "#/" ++ String.join "/" pieces


href : Route -> Html.Attribute msg
href route =
    Attrs.href <| toString route
