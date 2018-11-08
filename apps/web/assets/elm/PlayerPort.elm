port module PlayerPort exposing (Model, Msg(..), PlayState(..), PortOutMsg(..), addToCurrentPlaylist, decodeCmdIn, init, playStateToString, playTrack, playerCmdIn, playerCmdOut, playerView, sendPlayerCmd, update)

import Data.Track as Track exposing (Track)
import Html exposing (Html, a, aside, audio, button, div, header, i, li, nav, p, source, span, text, ul)
import Html.Attributes as Attrs
import Html.Events as Events
import Json.Decode as Decode
import Json.Encode as Serial


type PlayState
    = OnPause
    | OnPlay


playStateToString : PlayState -> String
playStateToString state =
    case state of
        OnPause ->
            "paused"

        OnPlay ->
            "playing"


type alias PlayerState =
    { track : Track
    , playState : PlayState
    , time : String
    , progress : Float
    }


initPlayerState : Track -> PlayerState
initPlayerState track =
    { track = track
    , playState = OnPause
    , time = stringifyTime 0
    , progress = 0
    }


setTime : String -> PlayerState -> PlayerState
setTime time playerState =
    { playerState | time = time }


setProgress : Float -> PlayerState -> PlayerState
setProgress progress playerState =
    { playerState | progress = progress }


setTrack : Track -> PlayerState -> PlayerState
setTrack track playerState =
    { playerState | track = track }


setPlayState : PlayState -> PlayerState -> PlayerState
setPlayState playState playerState =
    { playerState | playState = playState }


type Model
    = InActive
    | Active
        { playerState : PlayerState
        , currentPlaylist : List Track
        , pastPlaylist : List Track
        }


setPlayerState : PlayerState -> { m | playerState : PlayerState } -> { m | playerState : PlayerState }
setPlayerState playerState state =
    { state | playerState = playerState }


init : Model
init =
    InActive


initActive : Track -> Model
initActive track =
    Active
        { playerState = initPlayerState track
        , currentPlaylist = []
        , pastPlaylist = []
        }


playerView : Model -> Html Msg
playerView model =
    case model of
        InActive ->
            text ""

        Active ({ playerState, currentPlaylist, pastPlaylist } as state) ->
            let
                displayTitle =
                    Maybe.withDefault "Unknown track"

                ( track, time, totalTime ) =
                    let
                        currentTrack =
                            playerState.track
                    in
                    ( displayTitle currentTrack.title, playerState.time, formatTime currentTrack.duration )
            in
            div
                [ Attrs.id "player"
                , Attrs.class "level"
                ]
                [ controlBlock state
                , span [ Attrs.class "player-elem level-left" ] [ text time ]
                , progressBar playerState
                , span [ Attrs.class "player-elem" ] [ text totalTime ]
                , span [ Attrs.class "player-elem" ] [ text track ]
                ]


controlBlock :
    { playerState : PlayerState
    , currentPlaylist : List Track
    , pastPlaylist : List Track
    }
    -> Html Msg
controlBlock { playerState, currentPlaylist, pastPlaylist } =
    let
        ( playStateIcon, playEventAsList ) =
            let
                playEvent =
                    [ Events.onClick <| Send TogglePlay ]
            in
            case playerState.playState of
                OnPlay ->
                    ( "fas fa-pause", playEvent )

                OnPause ->
                    ( "fas fa-play", playEvent )

        nextEvent =
            case currentPlaylist of
                [] ->
                    []

                _ ->
                    [ Events.onClick Next ]
    in
    div [ Attrs.id "player-controls", Attrs.class "player-elem level-left" ]
        [ button (Attrs.class "icon" :: []) [ i [ Attrs.class "fas fa-backward" ] [] ]
        , button (Attrs.class "icon" :: playEventAsList) [ i [ Attrs.class playStateIcon ] [] ]
        , button (Attrs.class "icon" :: nextEvent) [ i [ Attrs.class "fas fa-forward" ] [] ]
        ]


progressBar : PlayerState -> Html Msg
progressBar playerState =
    let
        flip f a b =
            f b a

        progress =
            (playerState.progress * 100)
                |> String.fromFloat
                |> flip String.append "%"
    in
    div
        [ Attrs.id "timeline-wrapper"
        , Attrs.class "player-elem level-left"
        ]
        [ div [ Attrs.class "player-timeline-background" ] []
        , div
            [ Attrs.class "player-progress-done"
            , Attrs.style "width" progress
            , Attrs.style "background" "red"
            , Attrs.style "height" "1px"
            , Attrs.style "min-width" "1px"
            , Attrs.style "position" "absolute"
            ]
            []
        ]


type PortOutMsg
    = TogglePlay
    | PlayTrack Track


type Msg
    = TimeChange Float
    | Paused
    | Played
    | Send PortOutMsg
    | NoOp
    | AddToCurrentPlayList Track
    | Next
    | Previous


port playerCmdOut : Serial.Value -> Cmd msg


port playerCmdIn : (Serial.Value -> msg) -> Sub msg


decodeCmdIn : Decode.Value -> Msg
decodeCmdIn value =
    value
        |> (Decode.oneOf
                [ Decode.map TimeChange Decode.float
                , Decode.string
                    |> Decode.andThen
                        (\received ->
                            case received of
                                "pause" ->
                                    Decode.succeed Paused

                                "play" ->
                                    Decode.succeed Played

                                _ ->
                                    let
                                        failString =
                                            "Trying to decoce incoming msg but msg " ++ received ++ " is not recognized"
                                    in
                                    let
                                        _ =
                                            Debug.log failString ()
                                    in
                                    Decode.fail failString
                        )
                ]
                |> Decode.decodeValue
           )
        |> Result.withDefault NoOp


sendPlayerCmd : PortOutMsg -> Cmd msg
sendPlayerCmd msg =
    (case msg of
        TogglePlay ->
            Serial.object [ ( "action", Serial.string "togglePlay" ) ]

        PlayTrack track ->
            Serial.object [ ( "action", Serial.string "playTrack" ), ( "track", Track.encode track ) ]
    )
        |> playerCmdOut


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    let
        doNothing =
            ( model, Cmd.none )
    in
    case msg of
        Send TogglePlay ->
            case model of
                InActive ->
                    doNothing

                _ ->
                    ( model, sendPlayerCmd TogglePlay )

        Send (PlayTrack track) ->
            case model of
                InActive ->
                    ( initActive track, sendPlayerCmd (PlayTrack track) )

                Active state ->
                    ( Active
                        { state
                            | pastPlaylist = state.playerState.track :: state.pastPlaylist
                            , playerState =
                                state.playerState
                                    |> setTrack track
                        }
                    , sendPlayerCmd <| PlayTrack track
                    )

        TimeChange time ->
            case model of
                InActive ->
                    doNothing

                Active state ->
                    let
                        progress =
                            let
                                durationFloat =
                                    toFloat state.playerState.track.duration
                            in
                            time / durationFloat
                    in
                    ( state
                        |> setPlayerState
                            (state.playerState
                                |> setTime (stringifyTime time)
                                |> setProgress progress
                            )
                        |> Active
                    , Cmd.none
                    )

        Paused ->
            case model of
                InActive ->
                    doNothing

                Active state ->
                    ( state
                        |> setPlayerState (setPlayState OnPause state.playerState)
                        |> Active
                    , Cmd.none
                    )

        Played ->
            case model of
                InActive ->
                    doNothing

                Active state ->
                    ( state
                        |> setPlayerState (setPlayState OnPlay state.playerState)
                        |> Active
                    , Cmd.none
                    )

        AddToCurrentPlayList track ->
            case model of
                InActive ->
                    ( initActive track, sendPlayerCmd (PlayTrack track) )

                Active state ->
                    ( Active { state | currentPlaylist = state.currentPlaylist ++ [ track ] }, Cmd.none )

        Next ->
            case model of
                InActive ->
                    ( model, Cmd.none )

                Active { playerState, currentPlaylist, pastPlaylist } ->
                    case currentPlaylist of
                        nextTrack :: nextPlaylist ->
                            let
                                newModel =
                                    Active
                                        { playerState = initPlayerState nextTrack
                                        , currentPlaylist = nextPlaylist
                                        , pastPlaylist = playerState.track :: pastPlaylist
                                        }
                            in
                            ( newModel, sendPlayerCmd <| PlayTrack nextTrack )

                        [] ->
                            ( model, Cmd.none )

        Previous ->
            case model of
                InActive ->
                    doNothing

                Active { playerState, currentPlaylist, pastPlaylist } ->
                    case pastPlaylist of
                        previousTrack :: previousPlaylist ->
                            let
                                newModel =
                                    Active
                                        { playerState = initPlayerState previousTrack
                                        , currentPlaylist = playerState.track :: currentPlaylist
                                        , pastPlaylist = previousPlaylist
                                        }
                            in
                            ( newModel, sendPlayerCmd <| PlayTrack previousTrack )

                        [] ->
                            doNothing

        NoOp ->
            doNothing


stringifyTime : Float -> String
stringifyTime receivedTime =
    let
        totalSeconds =
            round receivedTime
    in
    formatTime totalSeconds


formatTime : Int -> String
formatTime totalSeconds =
    let
        ( minutes, seconds ) =
            ( totalSeconds // 60, modBy 60 totalSeconds )
    in
    let
        formatedMinutes =
            String.fromInt minutes

        formatedSeconds =
            seconds
                |> String.fromInt
                |> String.padLeft 2 '0'
    in
    formatedMinutes ++ ":" ++ formatedSeconds


playTrack : Track -> Msg
playTrack track =
    track
        |> PlayTrack
        |> Send


addToCurrentPlaylist : Track -> Msg
addToCurrentPlaylist track =
    track
        |> AddToCurrentPlayList
