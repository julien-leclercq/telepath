port module PlayerPort exposing (Model, Msg(..), PlayState(..), PortOutMsg(..), init, playStateToString, playTrack, playerCmdIn, playerCmdOut, playerView, sendPlayerCmd, update)

import Data.Track as Track exposing (Track)
import Html exposing (Html, a, aside, audio, button, div, header, i, li, nav, p, source, span, text, ul)
import Html.Attributes as Attrs
import Html.Events as Events
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


type alias Model =
    { track : Maybe Track.Track
    , playState : PlayState
    , time : String
    }


init : Model
init =
    { track = Nothing
    , playState = OnPause
    , time = stringifyTime 0
    }


playerView : Model -> Html Msg
playerView model =
    let
        displayTitle =
            Maybe.withDefault "Unknown track"

        ( track, time ) =
            case model.track of
                Nothing ->
                    ( "Choose a track !", "" )

                Just currentTrack ->
                    ( displayTitle currentTrack.title, model.time )
    in
    div
        [ Attrs.id "player"
        , Attrs.class "level"
        ]
        [ controlBlock
        , span [ Attrs.class "column" ] [ text time ]
        , span [ Attrs.class "column" ] [ text track ]
        ]


controlBlock =
    div [ Attrs.class "player-controls column" ]
        [ button [ Attrs.class "icon", Events.onClick <| Send TogglePlay ] [ i [ Attrs.class "fas fa-play" ] [] ]
        ]


type PortOutMsg
    = TogglePlay
    | PlayTrack Track


type Msg
    = TimeChange Float
    | Send PortOutMsg


port playerCmdOut : Serial.Value -> Cmd msg


port playerCmdIn : (Float -> msg) -> Sub msg


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
            case model.track of
                Nothing ->
                    ( model, Cmd.none )

                Just track ->
                    ( model, sendPlayerCmd TogglePlay )

        Send (PlayTrack track) ->
            let
                newModel =
                    { model | track = Just track, playState = OnPlay, time = stringifyTime 0 }
            in
            ( newModel, sendPlayerCmd (PlayTrack track) )

        TimeChange time ->
            ( { model | time = stringifyTime time }, Cmd.none )


stringifyTime receivedTime =
    let
        totalSeconds =
            floor receivedTime
    in
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
