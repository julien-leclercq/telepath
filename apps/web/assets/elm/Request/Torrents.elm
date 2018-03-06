module Request.Torrents exposing (getTorrents)

import Data.Torrent exposing (Torrent, File)
import Http


endpoint : String
endpoint =
    "/api/torrents"


getTorrents : Http.Request (List Torrent)
getTorrents =
    Http.get endpoint torrentListDecoder
