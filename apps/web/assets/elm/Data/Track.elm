module Data.Track exposing (Track, encode, trackDecoder)

import Json.Decode as Decode exposing (int, nullable, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode


type alias Track =
    { title : Maybe String
    , album : Maybe String
    , artist : Maybe String
    , id : Int
    , path : String
    }


trackDecoder : Decode.Decoder Track
trackDecoder =
    succeed Track
        |> required "title" (nullable string)
        |> required "album" (nullable string)
        |> required "artist" (nullable string)
        |> required "id" int
        |> required "path" string


encode : Track -> Encode.Value
encode track =
    Encode.object
        [ ( "id", Encode.int track.id )
        , ( "route", Encode.string <| "api/tracks/" ++ String.fromInt track.id )
        ]