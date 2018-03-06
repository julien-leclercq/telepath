module View exposing (..)

import Html exposing (Html, a, aside, div, header, li, nav, p, text, ul)
import Html.Attributes as Attrs
import Routes


appLayout : Html msg -> Html msg
appLayout view =
    div []
        [ navView
        , div [ Attrs.class "section" ]
            [ div [ Attrs.class "columns" ]
                [ menuView
                , view
                ]
            ]
        ]


navView : Html msg
navView =
    header [ Attrs.class "hero is-light" ]
        [ div [ Attrs.class "hero-head" ]
            [ nav [ Attrs.class "navbar has-shadow" ]
                [ div [ Attrs.class "navbar-brand" ]
                    [ div [ Attrs.class "navbar-item" ]
                        [ text "transmission" ]
                    ]
                ]
            ]
        ]


menuView : Html msg
menuView =
    aside [ Attrs.class "column is-2" ]
        [ nav [ Attrs.class "menu" ]
            [ p [ Attrs.class "menu-label" ]
                [ text "torrents" ]
            , ul [ Attrs.class "menu-list" ]
                [ li []
                    [ a [ Routes.href Routes.TorrentList ] [ text "List" ] ]
                , li []
                    [ a [ Routes.href Routes.Settings ] [ text "Settings" ]
                    ]
                ]
            ]
        ]


errorDiv maybeErrorText =
    let
        errorText =
            case maybeErrorText of
                Nothing ->
                    "You have encountered an error OR maybe this page is not implemented yet"

                Just errorText ->
                    errorText
    in
        div
            []
            [ p [] [ text errorText ] ]
            |> appLayout
