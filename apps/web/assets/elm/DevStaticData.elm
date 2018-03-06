module DevStaticData exposing (torrents)

import Data.Torrent exposing (Torrent)


torrents : List Torrent
torrents =
    [ { id = 1
      , seedboxId = 1
      , name = "torrent 1"
      , downloadDir = "/user/Downloads/torrents"
      , tracker = "such tracker"
      , files =
            [ { name = "file 1", bytesCompleted = "45", length = "176" }
            , { name = "file 2", bytesCompleted = "38", length = "3456" }
            ]
      }
    , { id = 2
      , seedboxId = 1
      , name = "torrent 14"
      , tracker = "very tracker"
      , downloadDir = "/user/Downloads/torrents"
      , files = []
      }
    , { id = 3
      , seedboxId = 1
      , name = "torrent 3"
      , tracker = "much pirate"
      , downloadDir = "/user/Downloads/torrents"
      , files = []
      }
    ]
