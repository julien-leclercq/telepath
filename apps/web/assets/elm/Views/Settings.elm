module Views.Settings exposing (..)

import Debug
import Html exposing (Html, a, div, li, text, ul)
import Html.Attributes as Attrs
import Html.Events as Events
import Pages.Settings as Page
import Data.Seedbox as Box
import Types


view : Page.Model -> Html Page.Msg
view model =
    div [ Attrs.class "container" ]
        [ tabs model
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
