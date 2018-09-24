module Views.TrackList exposing (view)

import Data.Track exposing (Track)
import Html exposing (div, text)
import Pages.Tracks exposing (Model, Msg)
import RemoteData


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
    div [] [ text track.title ]
