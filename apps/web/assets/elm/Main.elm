module Main exposing (..)

import Data.Torrent exposing (Torrent)
import Html exposing (..)
import Html.Attributes exposing (class, attribute)
import Navbar exposing (navView)
import Menu exposing (menuView)
import Types exposing (Model, Message)
import View.Torrent exposing (torrentsView)


torrents : Model
torrents =
    [ { id = 1
      , name = "torrent 1"
      , downloadDir = "/user/Downloads/torrents"
      , files = [ { name = "file 1", bytesCompleted = 45, length = 176 } ]
      }
    , { id = 2
      , name = "torrent 3"
      , downloadDir = "/user/Downloads/torrents"
      , files = []
      }
    , { id = 3
      , name = "torrent 3"
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
                , torrentsView torrents
                ]
            ]
        ]



-- Main


main : Platform.Program Basics.Never Model Message
main =
    beginnerProgram
        { model = torrents
        , update = update
        , view = mainView
        }
