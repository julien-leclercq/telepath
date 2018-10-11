module View exposing (appLayout, errorDiv, menuView, navView)

import Html exposing (Html, a, aside, audio, button, div, header, li, nav, p, source, text, ul)
import Html.Attributes as Attrs
import Routes


appLayout : Html msg -> Html msg -> Html msg
appLayout playerView view =
    div []
        [ navView
        , div [ Attrs.class "section" ]
            [ div [ Attrs.class "columns" ]
                [ menuView
                , view
                ]
            ]
        , playerView
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


errorDiv : Maybe String -> Html msg
errorDiv maybeErrorText =
    let
        defaultErrorText =
            "You have encountered an error OR maybe this page is not implemented yet"

        errorText =
            Maybe.withDefault defaultErrorText maybeErrorText
    in
        div
            []
            [ p [] [ text errorText ] ]
