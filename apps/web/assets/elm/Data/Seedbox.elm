module Data.Seedbox exposing (..)

import Json.Encode as Encode
import Json.Decode as Decode exposing (andThen, bool, int, fail, field, list, nullable, string)
import Json.Decode.Pipeline exposing (decode, required)


type Seedbox
    = Remote RemoteSeedbox


type alias RemoteSeedbox =
    { accessible : Bool
    , host : String
    , id : String
    , name : String
    , port_ : String
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
        |> required "accessible" bool
        |> required "host" string
        |> required "id" string
        |> required "name" string
        |> required "port" string


seedboxEncoder : Seedbox -> Encode.Value
seedboxEncoder seedbox =
    let
        encodedSeedbox =
            case seedbox of
                Remote seedbox ->
                    remoteSeedboxEncoder seedbox
    in
        Encode.object [ ( "seedbox", encodedSeedbox ) ]


remoteSeedboxEncoder : RemoteSeedbox -> Encode.Value
remoteSeedboxEncoder seedbox =
    Encode.object
        [ ( "host", Encode.string seedbox.host ), ( "port", Encode.string seedbox.port_ ) ]


url : Seedbox -> String
url seedbox =
    case seedbox of
        Remote seedbox ->
            seedbox.host


id : Seedbox -> String
id (Remote seedbox) =
    seedbox.id


updateHost : String -> Seedbox -> Seedbox
updateHost host (Remote seedbox) =
    Remote { seedbox | host = host }


updatePort : String -> Seedbox -> Seedbox
updatePort port_ (Remote seedbox) =
    Remote { seedbox | port_ = port_ }
