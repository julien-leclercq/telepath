module Views.Settings exposing (..)

import Html exposing (Html, a, br, div, input, label, li, p, text, ul)
import Html.Attributes as Attrs
import Html.Events as Events
import Pages.Settings as Page
import Data.Seedbox as Box


view : Page.Model -> Html Page.Msg
view model =
    div [ Attrs.class "container" ]
        [ tabs model
        , form model
        ]


tab : Maybe a -> List (Html a) -> Html a
tab maybeMsg content =
    let
        attrs =
            case maybeMsg of
                Nothing ->
                    [ Attrs.class "is-active" ]

                Just msg ->
                    [ Events.onClick msg ]
    in
        li attrs [ a [] content ]


seedboxTabs : Page.Model -> List (Html Page.Msg)
seedboxTabs model =
    let
        name box =
            if (box |> Box.url) == "" then
                box
                    |> Box.id
                    |> toString
                    |> (++) "Box "
            else
                Box.url box
    in
        case model.state of
            Page.AddSeedbox _ ->
                List.map (\box -> tab (Just <| Page.GoToConfig box) [ text <| name box ]) model.seedboxes

            Page.ConfigSeedbox ( curBox, _ ) ->
                List.map
                    (\box ->
                        if curBox == box then
                            tab Nothing [ text <| name box ]
                        else
                            tab (Just <| Page.GoToConfig box) [ text <| name box ]
                    )
                    model.seedboxes


addSeedboxTab : Page.Model -> Html Page.Msg
addSeedboxTab model =
    let
        msg =
            case model.state of
                Page.AddSeedbox _ ->
                    Nothing

                _ ->
                    Just Page.FreshSeedbox
    in
        tab msg [ text "Add +" ]


tabs : Page.Model -> Html Page.Msg
tabs model =
    div [ Attrs.class "tabs" ]
        [ ul [] (addSeedboxTab model :: seedboxTabs model)
        ]


form : Page.Model -> Html Page.Msg
form model =
    let
        formBody (Page.Remote box) =
            [ div [ Attrs.class "field" ]
                [ label [ Attrs.class "label" ] [ text "Url" ]
                , div [ Attrs.class "control" ]
                    [ input [ Attrs.class "input", Attrs.type_ "text", Attrs.placeholder "http://url-of-my-box.com", Attrs.value box.url ] []
                    ]
                , p [ Attrs.class "help" ] [ text "the url of your box.", br [] [], text "If your box is on the same server as your telepath, just put localhost in here" ]
                ]
            , div [ Attrs.class "field" ]
                [ label [ Attrs.class "label" ] [ text "Port" ]
                , div [ Attrs.class "control" ]
                    [ input [ Attrs.class "input", Attrs.type_ "text", Attrs.placeholder "9091", Attrs.value box.port_ ] []
                    ]
                ]
            ]
    in
        model
            |> Page.pendingSeedbox
            |> formBody
            |> div [ Attrs.class "form" ]
