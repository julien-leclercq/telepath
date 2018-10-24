port module PlayerPort exposing (Model, Msg(..), PlayState(..), PortOutMsg(..), nothing, playStateToString, playTrack, playerCmdIn, playerCmdOut, playerView, sendPlayerCmd, update)

import Data.Track as Track exposing (Track)
import Html exposing (Html, a, aside, audio, button, div, header,i, li, nav, p, source, span, text, ul)
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
    Maybe ( Track.Track, PlayState, String )


nothing : Model
nothing =
    Nothing


playerView : Model -> Html Msg
playerView model =
    let
        displayTitle = Maybe.withDefault "Unknown track"
        ( track, time ) =
            case model of
                Nothing ->
                    ( "Choose a track !", "" )

                Just ( currentTrack, currentPlaystate, currentTime ) ->
                    ( displayTitle currentTrack.title, currentTime )
    in
        div [ Attrs.id "player"
            ,Attrs.class "level"
            ]
            [ div [Attrs.class "player-controls column"] [
                    button [Attrs.class "icon", Events.onClick <| Send TogglePlay ] [i [Attrs.class "fas fa-play"] [] ]]
            , span [Attrs.class "column"] [ text track ]
            , span [Attrs.class "column"] [ text time ]
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
            ( Just ( track, OnPlay, stringifyTime 0 ), sendPlayerCmd (PlayTrack track) )

        TimeChange time ->
            model
                |> Maybe.map (\( x, y, _ ) -> ( x, y, stringifyTime time ))
                |> (\m -> ( m, Cmd.none ))

stringifyTime receivedTime =
    let
        seconds =
            floor receivedTime
    in String.fromInt seconds

playTrack : Track -> Msg
playTrack track =
    track
        |> PlayTrack
        |> Send
