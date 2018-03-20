module Main exposing (..)

import Html exposing (Html)
import Http
import Navigation exposing (program)
import Routes
import Pages.Settings as SettingsPage
import Pages.Torrents as TorrentsPage
import Views.Settings as Settings
import Views.TorrentList.List as TorrentList
import View exposing (appLayout, errorDiv)


type Page
    = TorrentListPage TorrentsPage.Model
    | SettingsPage SettingsPage.Model
    | ErrorPage (Maybe String)


type PageState
    = Loaded Page
    | TransitioningFrom Page


type alias Model =
    { pageState : PageState }


init : Navigation.Location -> ( Model, Cmd Message )
init location =
    setRoute
        (Routes.fromLocation
            location
        )
        { pageState = Loaded <| ErrorPage Nothing
        }


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page



-- View


renderApp : pageModel -> (pageModel -> Html pageMsg) -> (pageMsg -> Message) -> Html Message
renderApp pageModel pageView msgMapper =
    pageModel
        |> pageView
        |> appLayout
        |> Html.map msgMapper


mainView : Model -> Html Message
mainView model =
    case getPage model.pageState of
        TorrentListPage torrentsModel ->
            renderApp torrentsModel TorrentList.view TorrentsMsg

        SettingsPage settingsModel ->
            renderApp settingsModel Settings.view SettingsMsg

        ErrorPage maybeErrorText ->
            renderApp maybeErrorText errorDiv identity



-- UPDATE


type Message
    = None
    | UrlChange Navigation.Location
    | SettingsMsg SettingsPage.Msg
    | TorrentsMsg TorrentsPage.Msg
    | SettingsLoaded (Result Http.Error SettingsPage.Model)
    | TorrentsLoaded (Result Http.Error TorrentsPage.Model)


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    updatePage (getPage model.pageState) message model


updatePage : Page -> Message -> Model -> ( Model, Cmd Message )
updatePage page message model =
    case ( message, page ) of
        ( None, _ ) ->
            ( model, Cmd.none )

        ( UrlChange location, _ ) ->
            setRoute (Routes.fromLocation location) model

        ( SettingsMsg msg, SettingsPage submodel ) ->
            let
                ( ( newSubmodel, cmd ), msgFromPage ) =
                    SettingsPage.update msg submodel
            in
                case msgFromPage of
                    SettingsPage.NoOp ->
                        ( { model | pageState = Loaded <| SettingsPage newSubmodel }, Cmd.map SettingsMsg cmd )

        ( SettingsLoaded (Ok settingsModel), _ ) ->
            ( { model | pageState = Loaded <| SettingsPage settingsModel }, Cmd.none )

        ( SettingsLoaded (Err error), _ ) ->
            ( { model | pageState = Loaded <| ErrorPage <| Just "Error loading settings page" }, Cmd.none )

        ( TorrentsLoaded (Ok torrentsList), _ ) ->
            ( { model | pageState = Loaded <| TorrentListPage torrentsList }, Cmd.none )

        ( TorrentsLoaded (Err error), _ ) ->
            ( { model | pageState = Loaded <| ErrorPage <| Just "Error loading torrents index" }, Cmd.none )

        _ ->
            message
                |> Debug.log "Unable to catch message :"
                |> \_ -> ( model, Cmd.none )


setRoute : Maybe Routes.Route -> Model -> ( Model, Cmd Message )
setRoute maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | pageState = Loaded <| ErrorPage <| Just "Route didn't match" }, Cmd.none )

        Just Routes.Settings ->
            let
                msg =
                    Cmd.map SettingsLoaded SettingsPage.init
            in
                ( { model | pageState = TransitioningFrom <| getPage model.pageState }, msg )

        Just Routes.TorrentList ->
            let
                msg =
                    Cmd.map TorrentsLoaded TorrentsPage.init
            in
                ( { model | pageState = TransitioningFrom <| getPage model.pageState }, msg )



-- Main


main : Platform.Program Basics.Never Model Message
main =
    Navigation.program UrlChange
        { init = init
        , update = update
        , view = mainView
        , subscriptions = (\_ -> Sub.none)
        }
