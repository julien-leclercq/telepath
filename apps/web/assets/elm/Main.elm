module Main exposing (main)

import Browser
import Browser.Navigation as Navigation
import Debug
import Html exposing (Html)
import Http
import Pages.Settings as SettingsPage
import Pages.Torrents as TorrentsPage
import Pages.Tracks as TracksPage
import PlayerPort exposing (playerView)
import Routes
import Url
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
    { pageState : PageState
    , playerState : PlayerPort.Model
    , navKey : Navigation.Key
    }


baseModel : Navigation.Key -> Model
baseModel navKey =
    { pageState = Loaded <| ErrorPage Nothing
    , playerState = PlayerPort.init
    , navKey = navKey
    }


init : flags -> Url.Url -> Navigation.Key -> ( Model, Cmd Message )
init _ location navKey =
    setRoute
        (Routes.fromLocation
            location
        )
        (baseModel navKey)


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
    = ClickedLink Browser.UrlRequest
    | None
    | PlayerMsg PlayerPort.Msg
    | UrlChange Url.Url
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

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.External url ->
                    ( model, Navigation.load url )

                Browser.Internal url ->
                    ( model, Navigation.pushUrl model.navKey (Url.toString url) )

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

                        TracksPage.PlayerMsg playerMsg ->
                            let
                                ( updatedPlayerState, newPlayerCmd ) =
                                    PlayerPort.update model.playerState playerMsg
                            in
                            ( updatedPlayerState, Cmd.map PlayerMsg newPlayerCmd )
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
                        ( settingsModel, cmd ) =
                            SettingsPage.init
                    in
                    Cmd.map (\initMsg -> SettingsLoaded ( settingsModel, initMsg )) cmd
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
                        ( trackListModel, cmd ) =
                            TracksPage.init
                    in
                    Cmd.map (\initMsg -> TracksLoaded ( trackListModel, initMsg )) cmd
            in
            ( { model | pageState = TransitioningFrom <| getPage model.pageState }, msg )



-- Main


onUrlChange : Url.Url -> Message
onUrlChange =
    UrlChange


onUrlRequest : Browser.UrlRequest -> Message
onUrlRequest urlRequest =
    ClickedLink urlRequest


view : Model -> Browser.Document Message
view model =
    { title = "telepath"
    , body = [ mainView model ]
    }


main : Platform.Program String Model Message
main =
    let
        subscriptions =
            \_ ->
                PlayerPort.playerCmdIn PlayerPort.decodeCmdIn
                    |> Sub.map PlayerMsg

        -- Sub.none
        -- Browser.application UrlChange
        --     { init = init
        --     , update = update
        --     , view = mainView
        --     , subscriptions =
        --     }
        -- onUrlRequest =
        --     (\urlRequest ->
        --         case urlRequest of
        --             Internal url ->
        --                 Browser.Navigation.pushUrl
    in
    -- Browser.application
    --     { init = init
    --     , update = update
    --     , view = view
    --     , subscriptions = subscriptions
    --     , onUrlChange = onUrlChange
    --     , onUrlRequest = onUrlRequest
    --     }
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlChange = onUrlChange
        , onUrlRequest = onUrlRequest
        }
