module Data.Seedbox exposing (Seedbox, seedboxDecoder, seedboxListDecoder, seedboxEncoder, updateHost)

import Json.Encode as Encode
import Json.Decode as Decode exposing (andThen, bool, int, fail, field, list, nullable, string)
import Json.Decode.Pipeline exposing (decode, required)


type alias Seedbox =
    { accessible : Bool
    , host : String
    , id : String
    , name : String
    , port_ : Int
    }


seedboxListDecoder : Decode.Decoder (List Seedbox)
seedboxListDecoder =
    list seedboxDecoder


seedboxDecoder : Decode.Decoder Seedbox
seedboxDecoder =
    decode Seedbox
        |> required "accessible" bool
        |> required "host" string
        |> required "id" string
        |> required "name" string
        |> required "port" int


seedboxEncoder : ( String, String, Int ) -> Encode.Value
seedboxEncoder ( host, name, port_ ) =
    let
        encodedSeedbox =
            Encode.object [ ( "host", Encode.string host ), ( "name", Encode.string name ), ( "port", Encode.int port_ ) ]
    in
        Encode.object [ ( "seedbox", encodedSeedbox ) ]


host : Seedbox -> String
host seedbox =
    seedbox.host


id : Seedbox -> String
id =
    .id


updateHost : String -> Seedbox -> Seedbox
updateHost host seedbox =
    { seedbox | host = host }
