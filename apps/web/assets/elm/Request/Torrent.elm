module Request.Torrent exposing (list)

import Data.Torrent exposing (Torrent, File, torrentListDecoder)
import Http
import Json.Decode exposing (field)


endpoint : String
endpoint =
    "/api/torrents"


list : Http.Request (List Torrent)
list =
    Http.get endpoint <| field "torrents" torrentListDecoder