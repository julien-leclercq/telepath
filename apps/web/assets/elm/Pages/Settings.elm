module Pages.Settings exposing (..)

import Http exposing (Request)
import Request.Seedbox
import Types exposing (..)


type alias Model =
    { seedboxes : List Seedbox
    , state : State
    }


type State
    = AddSeedbox PendingSeedbox
    | ConfigSeedbox ( Seedbox, PendingSeedbox )


type PendingSeedbox
    = Remote
        { url : String
        , port_ : String
        }


type RemoteField
    = Url String
    | Port String


type Msg
    = GoToConfig Seedbox
    | FreshSeedbox
    | Input RemoteField
    | Push


type ExternalMsg
    = NoOp


init : Cmd (Result Http.Error Model)
init =
    Request.Seedbox.list
        |> Http.send
            (Result.map
                (\seedboxes ->
                    case seedboxes of
                        seedbox :: _ ->
                            { seedboxes = seedboxes, state = ConfigSeedbox ( seedbox, pendingFromSeedbox seedbox ) }

                        _ ->
                            { seedboxes = [], state = AddSeedbox freshSeedbox }
                )
            )


update : Msg -> Model -> ( ( Model, Cmd msg ), ExternalMsg )
update msg model =
    case msg of
        FreshSeedbox ->
            case model.state of
                AddSeedbox _ ->
                    ( ( model, Cmd.none ), NoOp )

                _ ->
                    let
                        newModel =
                            { model | state = AddSeedbox freshSeedbox }
                    in
                        ( ( newModel, Cmd.none ), NoOp )

        GoToConfig seedbox ->
            case model.state of
                ConfigSeedbox ( currentSeedbox, _ ) ->
                    let
                        newModel =
                            if seedbox == currentSeedbox then
                                model
                            else
                                { model | state = ConfigSeedbox ( seedbox, pendingFromSeedbox seedbox ) }
                    in
                        ( ( newModel, Cmd.none ), NoOp )

                _ ->
                    ( ( { model | state = ConfigSeedbox ( seedbox, pendingFromSeedbox seedbox ) }, Cmd.none ), NoOp )

        Input _ ->
            ( ( model, Cmd.none ), NoOp )

        Push ->
            ( ( model, Cmd.none ), NoOp )


freshSeedbox : PendingSeedbox
freshSeedbox =
    Remote { url = "localhost", port_ = "9091" }


portToString : Maybe Int -> String
portToString port_ =
    case port_ of
        Nothing ->
            ""

        Just p ->
            toString p


pendingFromSeedbox : Seedbox -> PendingSeedbox
pendingFromSeedbox seedbox =
    case seedbox of
        Types.Remote seedbox ->
            Remote { url = seedbox.url, port_ = portToString seedbox.port_ }


pendingSeedbox : Model -> PendingSeedbox
pendingSeedbox model =
    case model.state of
        AddSeedbox pendingSeedbox ->
            pendingSeedbox

        ConfigSeedbox ( _, pendingBox ) ->
            pendingBox
