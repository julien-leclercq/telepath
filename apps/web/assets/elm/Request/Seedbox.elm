module Request.Seedbox exposing (..)

import Data.Seedbox exposing (Seedbox, seedboxDecoder, seedboxListDecoder, seedboxEncoder)
import Json.Decode as Decode
import Http


url : String -> String
url endpoint =
    "/api/" ++ endpoint


endpoint : String
endpoint =
    url "seedboxes"


list : Http.Request (List Seedbox)
list =
    seedboxListDecoder
        |> Decode.field "seedboxes"
        |> Http.get endpoint


create : Seedbox -> Http.Request Seedbox
create seedbox =
    (seedbox
        |> seedboxEncoder
        |> Http.jsonBody
        |> Http.post endpoint
    )
    <|
        Decode.field "seedbox" seedboxDecoder
