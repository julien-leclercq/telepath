module Views.TrackList exposing (view)

import Data.Track exposing (Track)
import Html exposing (div, text)
import Html.Events as Events
import Pages.Tracks exposing (..)
import RemoteData
import PlayerPort


view : Model -> Html.Html Msg
view model =
    div []
        (case model of
            RemoteData.Success tracks ->
                List.map trackView tracks

            _ ->
                [ text "either the data is loading or an error occured " ]
        )


trackView : Track -> Html.Html Msg
trackView track =
    div [] [ div [ Events.onClick <| PlayTrack track ] [ text track.title ] ]
