module Data.Torrent exposing (Torrent, File)

import Json.Decode
    exposing
        ( Decoder
        , string
        , int
        , list
        )
import Json.Decode.Pipeline exposing (decode, required)


type alias Torrent =
    { id : Int
    , name : String
    , downloadDir : String
    , tracker : String
    , files : List File
    }


type alias File =
    { name : String
    , bytesCompleted : String -- in bytes
    , length : String -- in bytes
    }


torrentDecoder : Decoder Torrent
torrentDecoder =
    decode Torrent
        |> required "id" int
        |> required "name" string
        |> required "downloadDir" string
        |> required "tracker" string
        |> required "files" (list fileDecoder)


torrentListDecoder : Decoder (List Torrent)
torrentListDecoder =
    list torrentDecoder


fileDecoder : Decoder File
fileDecoder =
    decode File
        |> required "name" string
        |> required "bytesCompleted" string
        |> required "length" string
