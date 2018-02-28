module Main exposing (..)

import Data.Torrent exposing (Torrent)
import Html exposing (..)
import Html.Attributes exposing (class, attribute)
import Navbar exposing (navView)
import Navigation exposing (program)
import Routing
import Types exposing (..)
import View exposing (mainView)




init : Navigation.Location -> ( Model, Cmd Message )
init location =
    setRoute
        (Routing.fromLocation
            location
        )
        { availableBoxes = [ seedbox ]
        , currentBox = seedbox
        , pageState = Loaded TorrentListPage
      }



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        UrlChange location ->
            setRoute (Routing.fromLocation location) model

        _ ->
            ( model, Cmd.none )


setRoute : Maybe Routing.Route -> Model -> ( Model, Cmd Message )
setRoute maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( model, Cmd.none )

        Just Routing.Settings ->
            ( { model | pageState = Loaded SettingsPage }, Cmd.none )

        Just Routing.TorrentList ->
            ( { model | pageState = Loaded TorrentListPage }, Cmd.none )



-- Main


main : Platform.Program Basics.Never Model Message
main =
    Navigation.program UrlChange
        { init = init
        , update = update
        , view = mainView
        , subscriptions = (\_ -> Sub.none)
        }
