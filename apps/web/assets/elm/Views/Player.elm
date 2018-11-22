module Views.Player exposing (view)

import Data.Track exposing (Track)
import Html exposing (Html, button, div, i, span, text)
import Html.Attributes as Attrs
import Html.Events as Events
import Player exposing (..)
import Utils.Playlist as Playlist exposing (Playlist)
import Views.CurrentPlaylist as CurrentPlaylist


view : Player.Model -> Html Player.Msg
view model =
    case model of
        Player.InActive ->
            text ""

        Player.Active ({ playerState, playlist } as state) ->
            let
                displayTitle =
                    Maybe.withDefault "Unknown track"

                ( track, time, totalTime ) =
                    let
                        currentTrack =
                            playerState.track
                    in
                    ( displayTitle currentTrack.title, playerState.time, Player.formatTime currentTrack.duration )
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
                , CurrentPlaylist.view state.playlist
                ]


controlBlock :
    { playerState : PlayerState
    , playlist : Playlist Track
    }
    -> Html Msg
controlBlock { playerState, playlist } =
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

        ( nextEvent, isInactive ) =
            if Playlist.hasNext playlist then
                ( [], False )

            else
                ( [ Events.onClick Next ], True )
    in
    div [ Attrs.id "player-controls", Attrs.class "player-elem level-left" ]
        [ button
            (Attrs.class "icon" :: [])
            [ i [ Attrs.class "fas fa-backward" ] [] ]
        , button
            (Attrs.class "icon" :: playEventAsList)
            [ i [ Attrs.class playStateIcon ] [] ]
        , nextButton playlist
        ]


nextButton : Playlist a -> Html Msg
nextButton playlist =
    let
        _ =
            Debug.log "Playlist has next" <| Playlist.hasNext playlist
    in
    [ i [ Attrs.class "fas fa-forward" ] [] ]
        |> (if Playlist.hasNext playlist then
                button [ Attrs.class "icon", Events.onClick Next ]

            else
                button [ Attrs.class "icon disabled" ]
           )


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


currentPlaylistView :
    { playerState : PlayerState
    , currentPlaylist : List Track
    , pastPlaylist : List Track
    }
    -> Html Msg
currentPlaylistView state =
    div
        [ Attrs.id "playlist-panel"
        , Attrs.style "position" "fixed"
        , Attrs.style "right" "10px"
        , Attrs.style "bottom" "60px"
        , Attrs.style "width" "512px"
        , Attrs.style "height" "512px"
        , Attrs.style "background" "red"
        ]
        []
