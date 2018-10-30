module Views.Settings exposing (addSeedboxTab, authForm, errorDiv, hostField, nameField, portField, seedboxTabs, sessionForm, settingsForm, submitAndDeleteGroup, tab, tabs, view, warningDiv)

import Data.Seedbox as Seedbox
import Html exposing (Html, a, br, div, form, input, label, li, p, span, text, ul)
import Html.Attributes as Attrs
import Html.Events as Events
import Pages.Settings as Page exposing (pendingSeedboxOfState, stateOfModel)
import RemoteData


view : Page.Model -> Html Page.Msg
view model =
    div [ Attrs.class "container" ]
        (case model.seedboxes of
            RemoteData.Success _ ->
                [ tabs model
                , errorDiv model
                , warningDiv model
                , div [ Attrs.class "columns" ]
                    [ div [ Attrs.class "column is-half" ] [ settingsForm model ]
                    , div [ Attrs.class "column is-half" ] [ sessionForm model ]
                    ]
                ]

            RemoteData.Loading ->
                [ p [] [ text "loading available seedboxes" ]
                ]

            RemoteData.Failure error ->
                [ errorDiv model ]

            RemoteData.NotAsked ->
                [ p [] [ text "an unplanned action has occured" ] ]
        )


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
            if box.name /= "" then
                box.name

            else
                .host box
    in
    case model.seedboxes of
        RemoteData.Success seedboxes ->
            case model.state of
                Page.AddSeedbox ( _, _ ) ->
                    List.map (\box -> tab (Just <| Page.GoToConfig box) [ text <| name box ]) seedboxes

                Page.ConfigSeedbox ( curBox, _, _ ) ->
                    List.map
                        (\box ->
                            if curBox == box then
                                tab Nothing [ text <| name box ]

                            else
                                tab (Just <| Page.GoToConfig box) [ text <| name box ]
                        )
                        seedboxes

        _ ->
            []


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


settingsForm : Page.Model -> Html Page.Msg
settingsForm model =
    let
        formBody box =
            [ form [ Events.onSubmit <| Page.Push ]
                ([ nameField model
                 , hostField model
                 , portField model
                 ]
                    ++ authForm model
                    ++ submitAndDeleteGroup model
                )
            ]
    in
    model
        |> stateOfModel.get
        |> pendingSeedboxOfState.get
        |> formBody
        |> div [ Attrs.class "form" ]


errorDiv : Page.Model -> Html Page.Msg
errorDiv model =
    let
        noError =
            div [ Attrs.class "level" ] []

        error _ =
            let
                error =
                    "there is an error"
            in
            div [ Attrs.class "notification is-danger" ] [ text error ]
    in
    case model.state of
        Page.AddSeedbox ( _, RemoteData.Failure _ ) ->
            error ()

        Page.ConfigSeedbox ( _, _, RemoteData.Failure _ ) ->
            error ()

        _ ->
            noError


hostField : Page.Model -> Html Page.Msg
hostField model =
    let
        noErrorHelp =
            p [ Attrs.class "help" ] [ text "the url of your box.", br [] [], text "If your box is on the same server as your telepath, just put localhost in here" ]

        box =
            model |> stateOfModel.get |> pendingSeedboxOfState.get

        ( inputClass, help ) =
            case model.errors.host of
                [] ->
                    ( "input", noErrorHelp )

                firstError :: otherErrors ->
                    ( "input is-danger", p [ Attrs.class "help is-danger" ] (List.foldl (\error errors -> text error :: (br [] [] :: errors)) [ text firstError ] otherErrors) )
    in
    div [ Attrs.class "field" ]
        [ label [ Attrs.class "label" ] [ text "Host" ]
        , div [ Attrs.class "control" ]
            [ input [ Attrs.class inputClass, Attrs.type_ "text", Attrs.placeholder "http://url-of-my-box.com", Attrs.value box.host, Events.onInput (Page.input Page.Host) ] []
            ]
        , help
        ]


nameField : Page.Model -> Html Page.Msg
nameField model =
    let
        box =
            model |> stateOfModel.get |> pendingSeedboxOfState.get
    in
    div [ Attrs.class "field" ]
        [ label [ Attrs.class "label" ] [ text "Name of the Seedbox" ]
        , input [ Attrs.class "input", Attrs.value box.name, Events.onInput (Page.input Page.Name) ] []
        ]


portField : Page.Model -> Html Page.Msg
portField model =
    let
        noErrorHelp =
            p [ Attrs.class "help" ] [ text "the port of your seedbox 9091 by default" ]

        box =
            model |> stateOfModel.get |> pendingSeedboxOfState.get

        ( inputClass, help ) =
            case model.errors.port_ of
                [] ->
                    ( "input", noErrorHelp )

                firstError :: otherErrors ->
                    ( "input is-danger", p [ Attrs.class "help is-danger" ] (List.foldl (\error errors -> text error :: (br [] [] :: errors)) [ text firstError ] otherErrors) )
    in
    div [ Attrs.class "field" ]
        [ label [ Attrs.class "label" ] [ text "Port" ]
        , div [ Attrs.class "control" ]
            [ input [ Attrs.class inputClass, Attrs.type_ "text", Attrs.placeholder "http://url-of-my-box.com", Attrs.value box.port_, Events.onInput (Page.input Page.Port) ] []
            ]
        , help
        ]


submitAndDeleteGroup : Page.Model -> List (Html Page.Msg)
submitAndDeleteGroup model =
    case model.state of
        Page.ConfigSeedbox _ ->
            [ div [ Attrs.class "field is-grouped" ]
                [ div [ Attrs.class "control" ] [ input [ Attrs.class "field button is-success", Attrs.type_ "submit" ] [] ]
                , div [ Attrs.class "control" ] [ input [ Attrs.class "field button is-danger", Attrs.type_ "button", Attrs.value "Delete", Events.onClick Page.DeleteSeedbox ] [] ]
                ]
            ]

        _ ->
            [ div [ Attrs.class "field" ] [ input [ Attrs.class "field button", Attrs.type_ "submit" ] [] ]
            ]


warningDiv : Page.Model -> Html Page.Msg
warningDiv model =
    case model.state of
        Page.ConfigSeedbox ( box, _, _ ) ->
            let
                accessible =
                    box.accessible
            in
            if accessible then
                div [] []

            else
                div [ Attrs.class "notification is-warning" ] [ text "the seedbox is not accessible you should maybe add basic auth settings" ]

        _ ->
            div [] []


authForm : Page.Model -> List (Html Page.Msg)
authForm model =
    case model |> stateOfModel.get |> pendingSeedboxOfState.get |> .auth of
        Seedbox.NoAuth ->
            [ div [ Attrs.class "field" ]
                [ input [ Attrs.checked False, Attrs.class "switch", Attrs.id "auth-switch", Attrs.type_ "checkbox", Events.onCheck Page.ToggleAuth, Attrs.checked False ] []
                , label [ Attrs.for "auth-switch" ] [ text "Basic Auth disabled" ]
                ]
            ]

        Seedbox.BasicAuth ( name, password ) ->
            [ div [ Attrs.class "field" ]
                [ input [ Attrs.checked False, Attrs.class "switch", Attrs.id "auth-switch", Attrs.type_ "checkbox", Events.onCheck Page.ToggleAuth, Attrs.checked True ] []
                , label [ Attrs.for "auth-switch" ] [ text "Basic Auth enabled" ]
                ]
            , div [ Attrs.class "field" ]
                [ input [ Attrs.class "input", Attrs.placeholder "Name", Attrs.value name, Events.onInput (Page.input Page.AuthName) ] []
                ]
            , div [ Attrs.class "field" ] [ input [ Attrs.class "input", Attrs.placeholder "Password", Attrs.type_ "password", Events.onInput (Page.input Page.AuthPassword) ] [] ]
            ]


sessionForm : Page.Model -> Html Page.Msg
sessionForm _ =
    div [] [ text "here comes the session form" ]
