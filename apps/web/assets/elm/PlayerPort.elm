port module PlayerPort exposing (Model, Msg(..), PlayState(..), PortOutMsg(..), playStateToString, playTrack, playerCmdIn, playerCmdOut, playerView, sendPlayerCmd, update)

import Data.Track as Track exposing (Track)
import Html exposing (Html, a, aside, audio, button, div, header, li, nav, p, source, span, text, ul)
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
    Maybe ( Track.Track, PlayState, Float )


playerView : Model -> Html Msg
playerView model =
    let
        ( track, playstate, time ) =
            case model of
                Nothing ->
                    ( "", "", "" )

                Just ( track, playstate, time ) ->
                    ( track.title, playStateToString playstate, toString time )
    in
    div [ Attrs.class "level", Attrs.style "position" "fixed", Attrs.style "bottom" "0px", Attrs.style "width" "100%", Attrs.style "background" "white" ]
        [ button [ Events.onClick <| Send TogglePlay ]
            [ text "▶️"
            ]
        , span [] [ text track ]
        , span [] [ text time ]
        , span [] [ text playstate ]
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
            case model of
                Nothing ->
                    ( model, Cmd.none )

                Just ( track, playstate, _ ) ->
                    ( model, sendPlayerCmd TogglePlay )

        Send (PlayTrack track) ->
            ( Just ( track, OnPlay, 0 ), sendPlayerCmd (PlayTrack track) )

        TimeChange time ->
            model
                |> Maybe.map (\( x, y, _ ) -> ( x, y, time ))
                |> (\m -> ( m, Cmd.none ))


playTrack : Track -> Msg
playTrack track =
    track
        |> PlayTrack
        |> Send
