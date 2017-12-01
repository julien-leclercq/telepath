module Menu exposing (menuView)

import Html exposing (..)
import Html.Attributes exposing (class, attribute)


menuView : Html msg
menuView =
    aside [ class "column is-2" ]
        [ nav [ class "menu" ]
            [ p [ class "menu-label" ]
                [ text "torrents" ]
            ]
        ]
