module Main exposing (..)

import Data.Torrent exposing (Torrent)
import Html exposing (..)
import Html.Attributes exposing (class, attribute)
import Navbar exposing (navView)
import Navigation exposing (program)
import Menu exposing (menuView)
import Types exposing (Model, Message)
import TorrentList.List as TorrentList


torrents : Model
torrents =
    [ { id = 1
      , name = "torrent 1"
      , downloadDir = "/user/Downloads/torrents"
      , tracker = "such tracker"
      , files =
            [ { name = "file 1", bytesCompleted = "45", length = "176" }
            , { name = "file 2", bytesCompleted = "38", length = "3456" }
            ]
      }
    , { id = 2
      , name = "torrent 14"
      , tracker = "very tracker"
      , downloadDir = "/user/Downloads/torrents"
      , files = []
      }
    , { id = 3
      , name = "torrent 3"
      , tracker = "much pirate"
      , downloadDir = "/user/Downloads/torrents"
      , files = []
      }
    ]



-- UPDATE


update : Message -> Model -> Model
update _ model =
    model



-- View


mainView : Model -> Html Message
mainView torrents =
    div []
        [ navView
        , div [ class "section" ]
            [ div [ class "columns" ]
                [ menuView
                , TorrentList.view torrents
                ]
            ]
        ]



-- Main


main : Platform.Program Basics.Never Model Message
main =
    Navigation.program UrlChange
        { model = torrents
        , update = update
        , view = mainView
        , subscriptions = (\_ -> Sub.none)
        }
