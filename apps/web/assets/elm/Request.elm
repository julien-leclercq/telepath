@module Request exposing (Error, errorDecoder, delete, put)

import Http
import Json.Decode as Decode exposing (field)


type alias Error =
    String


errorDecoder : Decode.Decoder String
errorDecoder =
    field "errors" Decode.string


put : String -> Http.Body -> Decode.Decoder a -> Http.Request a
put url body decoder =
    Http.request
        { body = body
        , expect = Http.expectJson decoder
        , headers = []
        , method = "PUT"
        , timeout = Nothing
        , url = url
        , withCredentials = False
        }


delete : String -> Http.Request String
delete url =
    Http.request
        { body = Http.emptyBody
        , expect = Http.expectString
        , headers = []
        , method = "DELETE"
        , timeout = Nothing
        , url = url
        , withCredentials = False
        }
