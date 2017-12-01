module Data.Torrent exposing (Torrent, File)


type alias Torrent =
    { id : Int
    , name : String
    , downloadDir : String
    , files : List File
    }


type alias File =
    { name : String
    , bytesCompleted : Int -- in bytes
    , length : Int -- in bytes
    }
