module Types exposing (..)


type Seedbox
    = Remote RemoteSeedbox


type alias RemoteSeedbox =
    { id : Int
    , url : String
    , port_ : Maybe Int
    }
