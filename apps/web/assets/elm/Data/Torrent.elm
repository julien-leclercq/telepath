module Data.Torrent exposing (File, Torrent, torrentListDecoder)

import Json.Decode
    exposing
        ( Decoder
        , int
        , list
        , string
        , succeed
        )
import Json.Decode.Pipeline exposing (required)


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
    succeed Torrent
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
    succeed File
        |> required "name" string
        |> required "bytesCompleted" int
        |> required "length" int
