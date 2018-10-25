module Pages.Tracks exposing (ExtMsg(..), Model, Msg(..), init, update)

import Data.Track exposing (Track)
import PlayerPort
import RemoteData exposing (RemoteData, WebData)
import Request.Tracks


type alias RemoteTrackList =
    WebData (List Track)


type alias Model =
    { remoteTracks : RemoteTrackList
    , tracks : List Track
    }


type Msg
    = TrackListResponse RemoteTrackList
    | PlayTrack Track
    | Filter String


type ExtMsg
    = NoOp
    | PlayerMsg PlayerPort.Msg


init : ( Model, Cmd Msg )
init =
    ( { remoteTracks = RemoteData.Loading
      , tracks = []
      }
    , Request.Tracks.list |> RemoteData.sendRequest |> Cmd.map TrackListResponse
    )


update : Msg -> Model -> ( ( Model, Cmd msg ), ExtMsg )
update msg model =
    case msg of
        TrackListResponse remoteTracksResponse ->
            ( ( handleRemoteResponse remoteTracksResponse model, Cmd.none ), NoOp )

        PlayTrack track ->
            let
                trackRoute =
                    "api/tracks/" ++ String.fromInt track.id
            in
            ( ( model, Cmd.none ), PlayerMsg <| PlayerPort.playTrack track )

        Filter filter ->
            ( ( applyFilter model filter, Cmd.none ), NoOp )


applyFilter : Model -> String -> Model
applyFilter model filter =
    let
        downcasedFilter =
            filter
                |> String.trim
                |> String.toLower

        isFilteredField field =
            let
                downcasedField =
                    field
                        |> Maybe.withDefault ""
                        |> String.toLower
            in
            String.contains downcasedFilter downcasedField

        isFilteredTrack track =
            isFilteredField track.artist
                || isFilteredField track.title
                || isFilteredField track.album
    in
    case model of
        { remoteTracks } ->
            case remoteTracks of
                RemoteData.Success trackList ->
                    { model
                        | tracks =
                            List.filter isFilteredTrack trackList
                    }

                _ ->
                    model


handleRemoteResponse remoteTracksResponse model =
    case remoteTracksResponse of
        RemoteData.Success trackList ->
            { tracks = trackList
            , remoteTracks = remoteTracksResponse
            }

        _ ->
            model
