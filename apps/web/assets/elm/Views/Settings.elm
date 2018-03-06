module Views.Settings exposing (..)

import Html exposing (Html, a, div, li, text, ul)
import Html.Attributes as Attrs
import Html.Events as Events
import Pages.Settings as Page
import Data.Seedbox as Box
import Types


view : Page.Model -> Html Page.Msg
view model =
    div [ Attrs.class "container" ]
        [ div [ Attrs.class "tabs" ]
            [ ul []
                [ li [] [ a [] [ text "Seedbox 1" ] ]
                , li [ Attrs.class "is-active" ] [ a [] [ text "Add +" ] ]
                ]
            ]
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
        li attrs content


seedboxTabs : Page.Model -> List Types.Seedbox -> List (Html Page.Msg)
seedboxTabs model =
    case model.state of
        Page.AddSeedbox _ ->
            List.map (\box -> tab (Just <| Page.GoToConfig box) [ text <| Box.url box ])

        Page.ConfigSeedbox ( curBox, _ ) ->
            List.map
                (\box ->
                    let
                        url =
                            Box.url box
                    in
                        if curBox == box then
                            tab Nothing [ text <| Box.url box ]
                        else
                            tab (Just <| Page.GoToConfig box) [ text url ]
                )


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


tabs : Page.Model -> List Types.Seedbox -> Html Page.Msg
tabs model availableBoxes =
    div [ Attrs.class "tabs" ]
        [ ul [] (addSeedboxTab model :: seedboxTabs model availableBoxes)
        ]
