module Request.Torrents exposing (getTorrents)

import Data.Torrent exposing (Torrent, File)
import Json.Decode
    exposing
        ( Decoder
        , string
        , int
        , list
        )
import Json.Decode.Pipeline exposing (..)
import Http


endpoint : String
endpoint =
    "/api/torrents"


getTorrents : Http.Request (List Torrent)
getTorrents =
    Http.get endpoint torrentListDecoder


fileDecoder : Decoder File
fileDecoder =
    decode File
        |> required "name" string
        |> required "bytesComplented" int
        |> required "length" int


torrentDecoder : Decoder Torrent
torrentDecoder =
    decode Torrent
        |> required "id" int
        |> required "name" string
        |> required "downloadDir" string
        |> required "files" (list fileDecoder)


torrentListDecoder : Decoder (List Torrent)
torrentListDecoder =
    list torrentDecoder
