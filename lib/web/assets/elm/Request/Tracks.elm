module Request.Tracks exposing (list)

import Data.Track exposing (Track, trackDecoder)
import Http
import Json.Decode as Decode exposing (field)


endpoint : String
endpoint =
    "/api/tracks"


list : Http.Request (List Track)
list =
    Http.get endpoint <| field "tracks" (Decode.list trackDecoder)
