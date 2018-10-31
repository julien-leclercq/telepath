module Main exposing (Message(..), Model, Page(..), PageState(..), getPage, init, main, mainView, renderApp, setRoute, update, updatePage)

import Debug
import Html exposing (Html)
import Http
import Navigation exposing (program)
import Pages.Settings as SettingsPage
import Pages.Torrents as TorrentsPage
import Pages.Tracks as TracksPage
import PlayerPort exposing (playerView)
import Routes
import View exposing (appLayout, errorDiv)
import Views.Settings as Settings
import Views.TorrentList.List as TorrentList
import Views.TrackList as TrackList


type Page
    = TorrentListPage TorrentsPage.Model
    | SettingsPage SettingsPage.Model
    | TrackListPage TracksPage.Model
    | ErrorPage (Maybe String)


type PageState
    = Loaded Page
    | TransitioningFrom Page


type alias Model =
    { pageState : PageState, playerState : PlayerPort.Model }


init : Navigation.Location -> ( Model, Cmd Message )
init location =
    setRoute
        (Routes.fromLocation
            location
        )
        { pageState = Loaded <| ErrorPage Nothing
        , playerState = Nothing
        }


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page



-- View


renderApp : PlayerPort.Model -> pageModel -> (pageModel -> Html pageMsg) -> (pageMsg -> Message) -> Html Message
renderApp playerModel pageModel pageView msgMapper =
    let
        mappedPlayerView =
            Html.map PlayerMsg <| playerView playerModel
    in
    pageModel
        |> pageView
        |> Html.map msgMapper
        |> appLayout mappedPlayerView


mainView : Model -> Html Message
mainView model =
    let
        renderAppWithPlayer =
            renderApp model.playerState
    in
    case getPage model.pageState of
        TorrentListPage torrentsModel ->
            renderAppWithPlayer torrentsModel TorrentList.view TorrentsMsg

        SettingsPage settingsModel ->
            renderAppWithPlayer settingsModel Settings.view SettingsMsg

        TrackListPage tracksModel ->
            renderAppWithPlayer tracksModel TrackList.view TracksMsg

        ErrorPage maybeErrorText ->
            renderAppWithPlayer maybeErrorText errorDiv identity



-- UPDATE


type Message
    = None
    | PlayerMsg PlayerPort.Msg
    | UrlChange Navigation.Location
    | SettingsMsg SettingsPage.Msg
    | TorrentsMsg TorrentsPage.Msg
    | TracksMsg TracksPage.Msg
    | TracksLoaded ( TracksPage.Model, TracksPage.Msg )
    | SettingsLoaded ( SettingsPage.Model, SettingsPage.Msg )
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

        ( SettingsLoaded ( settingsModel, settingsMessage ), _ ) ->
            let
                ( ( newSettingsModel, newSettingsMsg ), noOp ) =
                    SettingsPage.update settingsMessage settingsModel
            in
            ( { model | pageState = Loaded <| SettingsPage newSettingsModel }, Cmd.map SettingsMsg newSettingsMsg )

        ( TorrentsLoaded (Ok torrentsList), _ ) ->
            ( { model | pageState = Loaded <| TorrentListPage torrentsList }, Cmd.none )

        ( TorrentsLoaded (Err error), _ ) ->
            let
                _ =
                    Debug.log "error loading torrents" error
            in
            ( { model | pageState = Loaded <| ErrorPage <| Just "Error loading torrents index" }, Cmd.none )

        ( TorrentsMsg msg, TorrentListPage subModel ) ->
            let
                ( newModel, newMsg ) =
                    TorrentsPage.update msg subModel
            in
            ( { model | pageState = Loaded <| TorrentListPage newModel }, Cmd.map TorrentsMsg newMsg )

        ( TracksLoaded ( trackListModel, tracksMsg ), _ ) ->
            let
                ( ( newTrackListModel, newTrackCmd ), trackExtMsg ) =
                    TracksPage.update tracksMsg trackListModel
            in
            ( { model | pageState = Loaded <| TrackListPage newTrackListModel }, Cmd.map TracksMsg newTrackCmd )

        ( TracksMsg msg, TrackListPage subModel ) ->
            --  weird code. should refacto
            let
                ( ( newTracksModel, newTracksMsg ), tracksExtMsg ) =
                    TracksPage.update msg subModel

                newTrackMsg =
                    Cmd.map TracksMsg newTracksMsg

                newModel =
                    { model | pageState = Loaded <| TrackListPage newTracksModel }

                ( newPlayerState, newMainMsg ) =
                    case tracksExtMsg of
                        TracksPage.NoOp ->
                            ( model.playerState, Cmd.none )

                        TracksPage.PlayerMsg msg ->
                            let
                                ( newPlayerState, newPlayerCmd ) =
                                    PlayerPort.update model.playerState msg
                            in
                            ( newPlayerState, Cmd.map PlayerMsg newPlayerCmd )
            in
            ( { newModel | playerState = newPlayerState }, Cmd.batch [ newTrackMsg, newMainMsg ] )

        ( PlayerMsg msg, _ ) ->
            let
                ( newPlayerState, newPlayerCmd ) =
                    PlayerPort.update model.playerState msg
            in
            ( { model | playerState = newPlayerState }, Cmd.map PlayerMsg newPlayerCmd )

        _ ->
            message
                |> Debug.log "Unable to catch message :"
                |> (\_ -> ( model, Cmd.none ))


setRoute : Maybe Routes.Route -> Model -> ( Model, Cmd Message )
setRoute maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | pageState = Loaded <| ErrorPage <| Just "Route didn't match" }, Cmd.none )

        Just Routes.Settings ->
            let
                msg =
                    let
                        ( model, cmd ) =
                            SettingsPage.init
                    in
                    Cmd.map (\msg -> SettingsLoaded ( model, msg )) cmd
            in
            ( { model | pageState = TransitioningFrom <| getPage model.pageState }, msg )

        Just Routes.TorrentList ->
            let
                msg =
                    Cmd.map TorrentsLoaded TorrentsPage.init
            in
            ( { model | pageState = TransitioningFrom <| getPage model.pageState }, msg )

        Just Routes.TrackList ->
            let
                msg =
                    let
                        ( model, cmd ) =
                            TracksPage.init
                    in
                    Cmd.map (\msg -> TracksLoaded ( model, msg )) cmd
            in
            ( { model | pageState = TransitioningFrom <| getPage model.pageState }, msg )



-- Main


main : Platform.Program Basics.Never Model Message
main =
    Navigation.program UrlChange
        { init = init
        , update = update
        , view = mainView
        , subscriptions =
            (\_ ->
                PlayerPort.playerCmdIn PlayerPort.TimeChange
                    |> Sub.map PlayerMsg
             -- Sub.none
            )
        }
