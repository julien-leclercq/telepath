module Data.Track exposing (Track, encode, trackDecoder)

import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Decode as Decode exposing (int, string)
import Json.Encode as Encode


type alias Track =
    { title : String
    , album : String
    , artist : String
    , id : Int
    , path : String
    }


trackDecoder : Decode.Decoder Track
trackDecoder =
    decode Track
        |> optional "title" string ""
        |> optional "album" string ""
        |> optional "artist" string ""
        |> required "id" int
        |> required "path" string


encode : Track -> Encode.Value
encode track =
    Encode.object
        [ ( "id", Encode.int track.id )
        , ( "route", Encode.string <| "api/tracks/" ++ toString track.id )
        ]
