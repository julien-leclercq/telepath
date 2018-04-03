module Request exposing (Error, errorDecoder)

import Json.Decode as Decode exposing (field)


type alias Error =
    String


errorDecoder : Decode.Decoder String
errorDecoder =
    field "errors" Decode.string
