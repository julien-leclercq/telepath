module Pages.Settings exposing (..)

import Data.Seedbox as Data exposing (Seedbox, updateHost)
import Debug
import Http
import Json.Decode exposing (decodeString, field, list, string, Decoder)
import Json.Decode.Pipeline as Decode
import Platform.Cmd
import RemoteData exposing (RemoteData, WebData)
import Request
import Request.Seedbox


type alias Model =
    { seedboxes : WebData (List Seedbox)
    , state : State
    , errors : Errors
    }


type State
    = AddSeedbox ( PendingSeedbox, RemoteData Errors Seedbox )
    | ConfigSeedbox ( Seedbox, PendingSeedbox, WebData Seedbox )


type alias PendingSeedbox =
    { auth : Data.Auth
    , host : String
    , name : String
    , port_ : String
    }


type alias Errors =
    { global : List String
    , host : List String
    , name : List String
    , port_ : List String
    }


type RemoteField
    = Host String
    | Port String


type ExternalMsg
    = NoOp


init : ( Model, Cmd Msg )
init =
    ( { seedboxes = RemoteData.Loading
      , state = AddSeedbox ( freshSeedbox, RemoteData.NotAsked )
      , errors = errors
      }
    , Request.Seedbox.list
        |> RemoteData.sendRequest
        |> Cmd.map SeedboxListResponse
    )


pendingFromSeedbox : Seedbox -> PendingSeedbox
pendingFromSeedbox seedbox =
    PendingSeedbox Data.NoAuth seedbox.host seedbox.name (toString seedbox.port_)


pendingSeedbox : Model -> PendingSeedbox
pendingSeedbox model =
    case model.state of
        AddSeedbox ( pendingSeedbox, _ ) ->
            pendingSeedbox

        ConfigSeedbox ( _, pendingBox, _ ) ->
            pendingBox



-- UPDATE --


type Msg
    = GoToConfig Seedbox
    | FreshSeedbox
    | Input RemoteField
    | CreateStatus (RemoteData Errors Seedbox)
    | UpdateStatus (WebData Seedbox)
    | Push
    | SeedboxListResponse (WebData (List Seedbox))


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        FreshSeedbox ->
            ( ( { model | state = AddSeedbox ( freshSeedbox, RemoteData.NotAsked ) }, Cmd.none ), NoOp )

        GoToConfig seedbox ->
            goToConfig seedbox model

        Input field ->
            ( ( { model | state = applyInput model.state field }, Cmd.none ), NoOp )

        Push ->
            ( pushSeedbox model, NoOp )

        SeedboxListResponse webData ->
            ( ( { model | seedboxes = webData }, Cmd.none ), NoOp )

        CreateStatus remoteData ->
            ( handleCreateResponse remoteData model, NoOp )

        UpdateStatus _ ->
            ( ( { model | errors = { errors | global = [ "HANDLING UPDATE SEEDBOX RESPONSE NOT IMPLEMENTED YET" ] } }, Cmd.none ), NoOp )


goToConfig : Seedbox -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
goToConfig seedbox model =
    case model.state of
        ConfigSeedbox ( currentBox, _, _ ) ->
            if currentBox == seedbox then
                ( ( model, Cmd.none ), NoOp )
            else
                ( ( { model | state = ConfigSeedbox ( seedbox, freshSeedbox, RemoteData.NotAsked ) }, Cmd.none ), NoOp )

        _ ->
            ( ( { model | state = ConfigSeedbox ( seedbox, freshSeedbox, RemoteData.NotAsked ) }, Cmd.none ), NoOp )


input : (String -> RemoteField) -> String -> Msg
input field value =
    Input (field value)


applyInput : State -> RemoteField -> State
applyInput state field =
    let
        updateBox box =
            case field of
                Host host ->
                    { box | host = host }

                Port port_ ->
                    { box | port_ = port_ }
    in
        case state of
            AddSeedbox ( box, webData ) ->
                AddSeedbox <| ( updateBox box, webData )

            ConfigSeedbox ( box, modifs, webData ) ->
                ConfigSeedbox ( box, updateBox modifs, webData )


freshSeedbox : PendingSeedbox
freshSeedbox =
    { auth = Data.NoAuth
    , name = ""
    , port_ = ""
    , host = ""
    }


verifySeedbox : PendingSeedbox -> Result Errors ( String, String, Int )
verifySeedbox pendingSeedbox =
    String.toInt pendingSeedbox.port_
        |> Result.map
            (\port_ ->
                ( pendingSeedbox.host, pendingSeedbox.name, port_ )
            )
        |> Result.mapError (\_ -> { errors | port_ = [ "Error parsing port to an int" ] })


pushSeedbox : Model -> ( Model, Cmd Msg )
pushSeedbox model =
    case model.state of
        AddSeedbox ( pendingSeedbox, _ ) ->
            pendingSeedbox
                |> verifySeedbox
                |> Debug.log "pushing seedbox from a AddSeedbox state"
                |> (\verified ->
                        case verified of
                            Result.Ok toEncode ->
                                Data.seedboxEncoder toEncode
                                    |> Request.Seedbox.create
                                    |> sendRequest
                                    |> (\cmd -> ( { model | state = AddSeedbox ( pendingSeedbox, RemoteData.Loading ) }, Cmd.map CreateStatus cmd ))

                            Result.Err errors ->
                                ( { model | errors = errors }, Cmd.none )
                   )

        _ ->
            Debug.crash "updating seedbox not implemented"



-- ( { model | errors = { errors | global = [ "UPDATE SEEDBOX NOT IMPLEMENTED" ] } }, Cmd.none )


sendRequest : Http.Request a -> Cmd (RemoteData Errors a)
sendRequest request =
    request
        |> RemoteData.sendRequest
        |> Cmd.map (RemoteData.mapError handleHttpErrors)


errors : Errors
errors =
    { global = []
    , host = []
    , name = []
    , port_ = []
    }


handleCreateResponse : RemoteData Errors Seedbox -> Model -> ( Model, Cmd Msg )
handleCreateResponse remoteData model =
    case remoteData of
        RemoteData.Failure e ->
            ( { model
                | errors = e
              }
            , Cmd.none
            )

        RemoteData.Success box ->
            ( { model | seedboxes = RemoteData.map ((::) box) model.seedboxes, state = ConfigSeedbox ( box, pendingFromSeedbox box, RemoteData.NotAsked ) }, Cmd.none )

        _ ->
            Debug.crash "Remote Data is in an unplanned state"


handleHttpErrors : Http.Error -> Errors
handleHttpErrors error =
    case error of
        Http.BadUrl _ ->
            { errors | global = [ "An unplanned error has occured" ] }

        Http.BadStatus { body } ->
            decodeString errorsDecoder body
                |> Result.withDefault ({ errors | global = [ "error decoding errors I have no more arguments" ] })

        Http.Timeout ->
            { errors | global = [ "network timeout" ] }

        Http.NetworkError ->
            { errors | global = [ "network unavailable" ] }

        Http.BadPayload error _ ->
            { errors | global = [ error ] }


errorsDecoder : Decoder Errors
errorsDecoder =
    let
        genericDecoder =
            Json.Decode.map (\global -> { errors | global = global }) Request.errorDecoder
    in
        Decode.decode Errors
            |> Decode.optional "host" (list string) []
            |> Decode.optional "name" (list string) []
            |> Decode.optional "port" (list string) []
            |> Decode.optional "global" (list string) []
