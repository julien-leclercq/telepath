module Pages.Tracks exposing (ExtMsg(..), Model, Msg(..), init, update)

import Data.Track exposing (Track)
import PlayerPort
import RemoteData exposing (RemoteData, WebData)
import Request.Tracks


type alias Model =
    WebData (List Track)


type Msg
    = TrackListResponse Model
    | PlayTrack Track


type ExtMsg
    = NoOp
    | PlayerMsg PlayerPort.Msg


init : ( Model, Cmd Msg )
init =
    ( RemoteData.Loading, Request.Tracks.list |> RemoteData.sendRequest |> Cmd.map TrackListResponse )


update : Msg -> Model -> ( ( Model, Cmd msg ), ExtMsg )
update msg model =
    case msg of
        TrackListResponse receivedModel ->
            ( ( receivedModel, Cmd.none ), NoOp )

        PlayTrack track ->
            let
                trackRoute =
                    "api/tracks/" ++ String.fromInt track.id
            in
                ( ( model, Cmd.none ), PlayerMsg <| PlayerPort.playTrack track )
