module Data.Track exposing (Track, trackDecoder)

import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Decode as Decode exposing (int, string)


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
