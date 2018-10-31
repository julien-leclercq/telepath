module Request.Seedbox exposing (create, delete, endpoint, list, update, url)

import Data.Seedbox exposing (Seedbox, seedboxDecoder, seedboxEncoder, seedboxListDecoder)
import Http
import Json.Decode as Decode
import Json.Encode as Json
import Request


url : String -> String
url path =
    "/api/" ++ path


endpoint : String
endpoint =
    url "seedboxes"


list : Http.Request (List Seedbox)
list =
    seedboxListDecoder
        |> Decode.field "seedboxes"
        |> Http.get endpoint


create : Json.Value -> Http.Request Seedbox
create seedboxJson =
    (seedboxJson
        |> Http.jsonBody
        |> Http.post endpoint
    )
    <|
        Decode.field "seedbox" seedboxDecoder


update : Seedbox -> Json.Value -> Http.Request Seedbox
update seedbox seedboxJson =
    (seedboxJson
        |> Http.jsonBody
        |> Request.put (endpoint ++ "/" ++ seedbox.id)
    )
    <|
        Decode.field "seedbox" seedboxDecoder


delete seedbox =
    Request.delete (endpoint ++ "/" ++ seedbox.id)
