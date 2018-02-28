module Types exposing (..)

import Data.Torrent exposing (Torrent)
import Navigation exposing (Location)


type alias Model =
    { availableBoxes : List Seedbox
    , currentBox : Seedbox
    , pageState : PageState
    }


type PageState
    = Loaded Page


type Seedbox
    = Remote RemoteSeedbox


type alias RemoteSeedbox =
    { torrents : List Torrent
    , settings : RemoteSeedboxSettings
    }


type alias RemoteSeedboxSettings =
    { url : String
    , port_ : Maybe Int
    }


type Message
    = None
    | AddTorrent
    | UrlChange Location


type Page
    = TorrentListPage
    | SettingsPage
