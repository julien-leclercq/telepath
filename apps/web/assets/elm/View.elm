module View exposing (..)

import DevStaticData
import Html exposing (Html, a, aside, div, header, nav, p, text)
import Html.Attributes as Attrs
import Html.Events as Events
import TorrentList.List as TorrentList
import Types exposing (..)


mainView : Model -> Html Message
mainView model =
    case model.pageState of
        Loaded TorrentListPage ->
            DevStaticData.torrents
                |> TorrentList.view
                |> appLayout

        _ ->
            div [] [] |> appLayout


appLayout : Html Message -> Html Message
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
            , a [ Attrs.class "menu-label", Attrs.href "settings" ] [ text "settings" ]
            ]
        ]
