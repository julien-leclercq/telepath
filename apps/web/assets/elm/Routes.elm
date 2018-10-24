module Routes exposing (Route(..), fromLocation, href, route, toString)

import Html
import Html.Attributes as Attrs
import Url
import Url.Parser as UrlParser


type Route
    = TorrentList
    | Settings
    | TrackList


fromLocation : Url.Url -> Maybe Route
fromLocation url =
    UrlParser.parse route url


route : UrlParser.Parser (Route -> Route) Route
route =
    UrlParser.oneOf
        [ UrlParser.map TorrentList UrlParser.top
        , UrlParser.map TorrentList (UrlParser.s "torrents")
        , UrlParser.map Settings (UrlParser.s "settings")
        , UrlParser.map TrackList (UrlParser.s "tracks")
        ]


toString : Route -> String
toString path =
    let
        pieces =
            case path of
                TorrentList ->
                    [ "torrents" ]

                Settings ->
                    [ "settings" ]

                TrackList ->
                    [ "tracks" ]
    in
        String.join "/" pieces


href : Route -> Html.Attribute msg
href path =
    Attrs.href <| toString path
