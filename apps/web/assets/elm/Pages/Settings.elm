module Pages.Settings exposing (..)

import Data.Seedbox as Data exposing (Seedbox, updateHost, updatePort)
import Debug
import Http exposing (Request, Response)
import Json.Decode exposing (decodeString, field, maybe, string, Decoder)
import Json.Decode.Pipeline as Decode
import Request
import Request.Seedbox


type alias Model =
    { seedboxes : List Seedbox
    , state : State
    , loading : Bool
    , errors : Errors
    }


type State
    = AddSeedbox PendingSeedbox
    | ConfigSeedbox ( Seedbox, PendingSeedbox )


type PendingSeedbox
    = Pending Seedbox


type RemoteField
    = Host String
    | Port String


type Msg
    = GoToConfig Seedbox
    | FreshSeedbox
    | Input RemoteField
    | CreateStatus (Result Http.Error Seedbox)
    | UpdateStatus (Result Http.Error Seedbox)
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
                            { seedboxes = seedboxes, state = ConfigSeedbox ( seedbox, Pending seedbox ), loading = False, errors = errors }

                        _ ->
                            { seedboxes = [], state = AddSeedbox freshSeedbox, loading = False, errors = errors }
                )
            )


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
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
                                { model | state = ConfigSeedbox ( seedbox, Pending seedbox ) }
                    in
                        ( ( newModel, Cmd.none ), NoOp )

                _ ->
                    ( ( { model | state = ConfigSeedbox ( seedbox, Pending seedbox ) }, Cmd.none ), NoOp )

        Input field ->
            ( ( { model | state = applyInput model.state field }, Cmd.none ), NoOp )

        Push ->
            ( ( { model | loading = True }, pushSeedbox model.state ), NoOp )

        CreateStatus result ->
            case result of
                Ok seedbox ->
                    Debug.log "seedbox created"
                        identity
                        ( ( { model
                                | seedboxes = seedbox :: model.seedboxes
                                , loading = False
                                , state = ConfigSeedbox ( seedbox, Pending seedbox )
                                , errors = errors
                            }
                          , Cmd.none
                          )
                        , NoOp
                        )

                Err error ->
                    let
                        errorMessages =
                            case error of
                                Http.BadStatus response ->
                                    response.body
                                        |> decodeString (field "errors" errorsDecoder)
                                        |> Result.withDefault { errors | global = Just "unable to decode data" }

                                Http.NetworkError ->
                                    { errors | global = Just "there seems to be a problem" }

                                Http.BadPayload httpError _ ->
                                    Debug.log "error bad payload" { errors | global = Just httpError }

                                Http.BadUrl url ->
                                    { errors | global = Just (url ++ " is not a valid url") }

                                Http.Timeout ->
                                    { errors | global = Just "request has timeout" }
                    in
                        Debug.log "Seedbox not created"
                            ( ( { model | loading = False, errors = errorMessages }, Cmd.none ), NoOp )

        _ ->
            ( ( model, Cmd.none ), NoOp )


input : (String -> RemoteField) -> String -> Msg
input field value =
    Input (field value)


applyInput : State -> RemoteField -> State
applyInput state field =
    let
        updateBox box =
            case field of
                Host host ->
                    updateHost host box

                Port port_ ->
                    updatePort port_ box
    in
        case state of
            AddSeedbox (Pending box) ->
                AddSeedbox <| Pending <| updateBox box

            ConfigSeedbox ( box, Pending modifs ) ->
                ConfigSeedbox ( box, Pending <| updateBox modifs )


freshSeedbox : PendingSeedbox
freshSeedbox =
    { accessible = False
    , auth = Data.NoAuth
    , id = ""
    , name = ""
    , port_ = ""
    , host = ""
    }
        |> Data.Remote
        |> Pending


portToString : Maybe Int -> String
portToString port_ =
    case port_ of
        Nothing ->
            ""

        Just p ->
            toString p


pendingSeedbox : Model -> Seedbox
pendingSeedbox model =
    case model.state of
        AddSeedbox (Pending pendingSeedbox) ->
            pendingSeedbox

        ConfigSeedbox ( _, Pending pendingBox ) ->
            pendingBox


pushSeedbox : State -> Cmd Msg
pushSeedbox state =
    case state of
        AddSeedbox (Pending pendingSeedbox) ->
            Request.Seedbox.create (pendingSeedbox)
                |> Http.send identity
                |> Cmd.map CreateStatus

        _ ->
            Cmd.none


type alias Errors =
    { url : Maybe String
    , port_ : Maybe String
    , global : Maybe String
    }


errors : Errors
errors =
    { url = Nothing
    , port_ = Nothing
    , global = Nothing
    }


errorsDecoder : Decoder Errors
errorsDecoder =
    let
        genericDecoder =
            Json.Decode.map (\global -> { errors | global = global }) Request.errorDecoder
    in
        Decode.decode Errors
            |> Decode.optional "host" (maybe string) Nothing
            |> Decode.optional "port" (maybe string) Nothing
            |> Decode.optional "global" (maybe string) Nothing
