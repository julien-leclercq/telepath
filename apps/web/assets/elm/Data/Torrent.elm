module Data.Torrent exposing (Torrent, File, torrentListDecoder)

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
    , seedboxId : String
    , name : String
    , downloadDir : String

    -- , trackers : List String
    , files : List File
    }


type alias File =
    { name : String
    , bytesCompleted : Int -- in bytes
    , length : Int -- in bytes
    }


torrentDecoder : Decoder Torrent
torrentDecoder =
    decode Torrent
        |> required "id" int
        |> required "seedbox_id" string
        |> required "name" string
        |> required "downloadDir" string
        -- |> required "trackers" (list string)
        |> required "files" (list fileDecoder)


torrentListDecoder : Decoder (List Torrent)
torrentListDecoder =
    list torrentDecoder


fileDecoder : Decoder File
fileDecoder =
    decode File
        |> required "name" string
        |> required "bytesCompleted" int
        |> required "length" int
