port module PlayerPort exposing (Model, Msg(..), PlayState(..), PortOutMsg(..), decodeCmdIn, init, playStateToString, playTrack, playerCmdIn, playerCmdOut, playerView, sendPlayerCmd, update)

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


type Model
    = InActive
    | Active
        { playerState :
            { track : Track
            , playState : PlayState
            , time : String
            }
        , currentPlaylist : List Track
        , pastPlaylist : List Track
        }


init : Model
init =
    InActive


initActive : Track -> Model
initActive track =
    Active
        { playerState =
            { track = track
            , playState = OnPause
            , time = stringifyTime 0
            }
        , currentPlaylist = []
        , pastPlaylist = []
        }


playerView : Model -> Html Msg
playerView model =
    let
        displayTitle =
            Maybe.withDefault "Unknown track"

        ( track, time, totalTime ) =
            case model of
                InActive ->
                    ( "Choose a track !", "", "" )

                Active { playerState } ->
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
        [ controlBlock model
        , span [ Attrs.class "column" ] [ text (time ++ " / " ++ totalTime) ]
        , span [ Attrs.class "column" ] [ text track ]
        ]


controlBlock : Model -> Html Msg
controlBlock model =
    let
        playStateIcon =
            case model of
                InActive ->
                    "fas fa-play inactive"

                Active { playerState } ->
                    case playerState.playState of
                        OnPlay ->
                            "fas fa-pause"

                        OnPause ->
                            "fas fa-play"
    in
    div [ Attrs.class "player-controls column" ]
        [ button [ Attrs.class "icon", Events.onClick <| Send TogglePlay ] [ i [ Attrs.class playStateIcon ] [] ]
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
    case msg of
        Send TogglePlay ->
            case model of
                InActive ->
                    ( model, Cmd.none )

                _ ->
                    ( model, sendPlayerCmd TogglePlay )

        Send (PlayTrack track) ->
            let
                newModel =
                    initActive track
            in
            ( newModel, sendPlayerCmd (PlayTrack track) )

        TimeChange time ->
            case model of
                InActive ->
                    ( model, Cmd.none )

                Active state ->
                    let
                        playerState =
                            state.playerState

                        newPlayerState =
                            { playerState | time = stringifyTime time }
                    in
                    ( Active { state | playerState = newPlayerState }, Cmd.none )

        Paused ->
            case model of
                InActive ->
                    ( model, Cmd.none )

                Active state ->
                    let
                        playerState =
                            state.playerState
                    in
                    let
                        newPlayerState =
                            { playerState | playState = OnPause }
                    in
                    ( Active { state | playerState = newPlayerState }, Cmd.none )

        Played ->
            case model of
                InActive ->
                    ( model, Cmd.none )

                Active state ->
                    let
                        playerState =
                            state.playerState
                    in
                    let
                        newPlayerState =
                            { playerState | playState = OnPlay }
                    in
                    ( Active { state | playerState = newPlayerState }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


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
