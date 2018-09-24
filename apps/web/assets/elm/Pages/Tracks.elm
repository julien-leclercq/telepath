module Pages.Tracks exposing (..)

import Data.Track exposing (Track)
import RemoteData exposing (RemoteData, WebData)
import Request.Tracks


type alias Model =
    WebData (List Track)


type Msg
    = TrackListResponse Model


init : ( Model, Cmd Msg )
init =
    ( RemoteData.Loading, Request.Tracks.list |> RemoteData.sendRequest |> Cmd.map TrackListResponse )


update (TrackListResponse receivedModel) model =
    ( receivedModel, Cmd.none )
