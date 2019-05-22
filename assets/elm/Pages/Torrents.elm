module Pages.Torrents exposing (Model, Msg(..), SortField(..), init, sort, update)

import Data.Torrent exposing (..)
import Http
import Request.Torrent as Request


type Msg
    = AddTorrent
    | Sort SortField


type alias Model =
    List Torrent


type SortField
    = Name


init : Cmd (Result Http.Error (List Torrent))
init =
    Request.list
        |> Http.send identity


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Sort sortField ->
            ( sort sortField model, Cmd.none )

        _ ->
            ( model, Cmd.none )


sort :
    SortField
    -> List Torrent
    -> List Torrent
sort sortField =
    case sortField of
        Name ->
            List.sortBy .name
