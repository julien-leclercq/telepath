module Data.Seedbox exposing (..)

import Json.Encode as Encode
import Json.Decode as Decode exposing (andThen, bool, int, fail, field, list, nullable, string)
import Json.Decode.Pipeline exposing (decode, required)
import Types exposing (..)


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
        |> required "id" int
        |> required "url" string
        |> required "port" (nullable int)


seedboxEncoder : Seedbox -> Encode.Value
seedboxEncoder seedbox =
    case seedbox of
        Remote seedbox ->
            remoteSeedboxEncoder seedbox


remoteSeedboxEncoder : RemoteSeedbox -> Encode.Value
remoteSeedboxEncoder seedbox =
    let
        encodedPort =
            case seedbox.port_ of
                Just p ->
                    Encode.int p

                Nothing ->
                    Encode.null
    in
        Encode.object
            [ ( "url", Encode.string seedbox.url ), ( "port", encodedPort ) ]


url seedbox =
    case seedbox of
        Remote seedbox ->
            seedbox.url
