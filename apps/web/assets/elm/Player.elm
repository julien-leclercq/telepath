port module Player exposing (Model(..), Msg(..), PlayState(..), PlayerState, PortOutMsg(..), addToCurrentPlaylist, decodeCmdIn, formatTime, init, playStateToString, playTrack, playerCmdIn, playerCmdOut, sendPlayerCmd, update)

import Data.Track as Track exposing (Track)
import Html exposing (Html, a, aside, audio, button, div, header, i, li, nav, p, source, span, text, ul)
import Html.Attributes as Attrs
import Html.Events as Events
import Json.Decode as Decode
import Json.Encode as Serial
import Utils.Playlist as Playlist exposing (Playlist(..))



---------------- MODEL


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
        , playlist : Playlist Track
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
        , playlist = Playlist.new track
        }



----------- VIEW
---------------- UPDATE


type PortOutMsg
    = TogglePlay
    | PlayTrack Track
    | Prepare Track


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

        Prepare track ->
            Serial.object [ ( "action", Serial.string "prepareTrack" ), ( "track", Track.encode track ) ]
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
                            | playlist =
                                Playlist.add track state.playlist
                            , playerState =
                                state.playerState
                                    |> setTrack track
                        }
                    , sendPlayerCmd <| PlayTrack track
                    )

        Send (Prepare track) ->
            case model of
                InActive ->
                    ( initActive track, sendPlayerCmd (Prepare track) )

                Active _ ->
                    doNothing

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
                    ( initActive track, sendPlayerCmd (Prepare track) )

                Active state ->
                    ( Active { state | playlist = Playlist.addAtEnd track state.playlist }, Cmd.none )

        Next ->
            case model of
                InActive ->
                    doNothing

                Active ({ playerState, playlist } as state) ->
                    case Playlist.down playlist of
                        Just newPlaylist ->
                            let
                                newModel =
                                    Active
                                        { state
                                            | playlist = newPlaylist
                                        }
                            in
                            ( newModel, sendPlayerCmd <| PlayTrack (Playlist.getCurrent newPlaylist) )

                        Nothing ->
                            ( model, Cmd.none )

        Previous ->
            case model of
                InActive ->
                    doNothing

                Active ({ playerState, playlist } as state) ->
                    case Playlist.up playlist of
                        Just newPlaylist ->
                            let
                                newModel =
                                    Active
                                        { state
                                            | playlist = newPlaylist
                                        }
                            in
                            ( newModel, sendPlayerCmd <| PlayTrack (Playlist.getCurrent newPlaylist) )

                        Nothing ->
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
