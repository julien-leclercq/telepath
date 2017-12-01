module Navbar exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, attribute)


navView : Html msg
navView =
    header [ class "hero is-light" ]
        [ div [ class "hero-head" ]
            [ nav [ class "navbar has-shadow" ]
                [ div [ class "navbar-brand" ]
                    [ div [ class "navbar-item" ]
                        [ text "transmission" ]
                    ]
                ]
            ]
        ]
