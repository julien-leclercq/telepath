module Views.TrackList exposing (view)

import Data.Track exposing (Track)
import Html exposing (div, input, span, table, tbody, td, text, th, thead, tr)
import Html.Attributes as Attrs
import Html.Events as Events
import Pages.Tracks exposing (..)
import PlayerPort
import RemoteData


view : Model -> Html.Html Msg
view model =
    div []
        (case model.remoteTracks of
            RemoteData.Success tracks ->
                [ div [ Attrs.class "level" ] [ input [ Events.onInput Filter ] [] ]
                , table [ Attrs.class "table" ]
                    [ thead []
                        [ tr []
                            [ th [] [ text "title" ]
                            , th [] [ text "artist" ]
                            , th [] [ text "album" ]
                            ]
                        ]
                    , tbody [] (List.map trackView model.tracks)
                    ]
                ]

            _ ->
                [ text "either the data is loading or an error occured " ]
        )


trackView : Track -> Html.Html Msg
trackView track =
    let
        displayInfo maybeInfo =
            case maybeInfo of
                Nothing ->
                    span [ Attrs.style "color" "red" ] [ text "missing track title" ]

                Just title ->
                    span [] [ text title ]
    in
    tr [ Events.onClick <| PlayTrack track ]
        [ td [] [ displayInfo track.title ]
        , td [] [ displayInfo track.artist ]
        , td [] [ displayInfo track.album ]
        ]
