module Data.Seedbox exposing (..)

import Json.Encode as Encode
import Json.Decode as Decode exposing (andThen, bool, int, fail, field, list, nullable, string)
import Json.Decode.Pipeline exposing (decode, required)


type Seedbox
    = Remote RemoteSeedbox


type alias RemoteSeedbox =
    { id : String
    , port_ : String
    , url : String
    }


seedboxListDecoder : Decode.Decoder (List Seedbox)
seedboxListDecoder =
    list seedboxDecoder


seedboxDecoder : Decode.Decoder Seedbox
seedboxDecoder =
    field "remote" bool
        |> andThen
            (\remote ->
                if remote then
                    Decode.map Remote remoteSeedboxDecoder
                else
                    fail "Cannot decode non remote seedbox yet, check further versions ;)"
            )


remoteSeedboxDecoder : Decode.Decoder RemoteSeedbox
remoteSeedboxDecoder =
    decode RemoteSeedbox
        |> required "id" string
        |> required "port" string
        |> required "url" string


seedboxEncoder : Seedbox -> Encode.Value
seedboxEncoder seedbox =
    case seedbox of
        Remote seedbox ->
            remoteSeedboxEncoder seedbox


remoteSeedboxEncoder : RemoteSeedbox -> Encode.Value
remoteSeedboxEncoder seedbox =
    Encode.object
        [ ( "url", Encode.string seedbox.url ), ( "port", Encode.string seedbox.port_ ) ]


url : Seedbox -> String
url seedbox =
    case seedbox of
        Remote seedbox ->
            seedbox.url


id : Seedbox -> String
id (Remote seedbox) =
    seedbox.id
