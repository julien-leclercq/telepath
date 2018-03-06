module Request.Seedbox exposing (..)

import Data.Seedbox exposing (seedboxDecoder, seedboxListDecoder, seedboxEncoder)
import Json.Decode as Decode
import Http
import Types exposing (..)


list : Http.Request (List Seedbox)
list =
    seedboxListDecoder
        |> Decode.field "seedboxes"
        |> Http.get "/api/seedboxes"


create : Seedbox -> Decode.Decoder a -> Http.Request a
create seedbox =
    seedbox
        |> seedboxEncoder
        |> Http.jsonBody
        |> Http.post "/seedboxes"
