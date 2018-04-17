module Pages.Settings exposing (..)

import Data.Seedbox as Data exposing (Seedbox)
import Debug
import Http
import Json.Decode exposing (decodeString, field, list, string, Decoder)
import Json.Decode.Pipeline as Decode
import Monocle.Lens as Lens exposing (Lens)
import Monocle.Optional as Optional exposing (Optional)
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
    | ConfigSeedbox ( Seedbox, PendingSeedbox, RemoteData Errors Seedbox )


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
    | Name String
    | Port String
    | AuthName String
    | AuthPassword String


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
    PendingSeedbox seedbox.auth seedbox.host seedbox.name (toString seedbox.port_)



-- Optic helpers


pendingSeedboxOfState : Lens State PendingSeedbox
pendingSeedboxOfState =
    Lens
        (\state ->
            case state of
                AddSeedbox ( pendingSeedbox, _ ) ->
                    pendingSeedbox

                ConfigSeedbox ( _, pendingBox, _ ) ->
                    pendingBox
        )
        (\pendingBox state ->
            case state of
                AddSeedbox ( _, remote ) ->
                    AddSeedbox ( pendingBox, remote )

                ConfigSeedbox ( box, _, remote ) ->
                    ConfigSeedbox ( box, pendingBox, remote )
        )


errorsOfModel : Lens Model Errors
errorsOfModel =
    Lens .errors (\e m -> { m | errors = e })


stateOfModel : Lens { b | state : a } a
stateOfModel =
    Lens .state (\s m -> { m | state = s })


seedboxRemoteDataOfState : Lens State (RemoteData Errors Seedbox)
seedboxRemoteDataOfState =
    let
        get state =
            case state of
                AddSeedbox ( _, rd ) ->
                    rd

                ConfigSeedbox ( _, _, rd ) ->
                    rd

        set rd state =
            case state of
                AddSeedbox ( pb, _ ) ->
                    AddSeedbox ( pb, rd )

                ConfigSeedbox ( sb, pb, _ ) ->
                    ConfigSeedbox ( sb, pb, rd )
    in
        Lens get set


freshSeedbox : PendingSeedbox
freshSeedbox =
    { auth = Data.NoAuth
    , name = ""
    , port_ = ""
    , host = ""
    }



-- UPDATE --


type Msg
    = CreateStatus (RemoteData Errors Seedbox)
    | DeleteSeedbox
    | DeleteSeedboxStatus (RemoteData Errors String)
    | FreshSeedbox
    | GoToConfig Seedbox
    | Input RemoteField
    | Push
    | SeedboxListResponse (WebData (List Seedbox))
    | ToggleAuth Bool
    | UpdateStatus (RemoteData Errors Seedbox)


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        DeleteSeedbox ->
            ( deleteSeedbox model, NoOp )

        DeleteSeedboxStatus remoteData ->
            ( handleDeleteStatus remoteData model, NoOp )

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

        ToggleAuth _ ->
            ( ( toggleAuth model, Cmd.none ), NoOp )

        UpdateStatus _ ->
            ( ( { model | errors = { errors | global = [ "HANDLING UPDATE SEEDBOX RESPONSE NOT IMPLEMENTED YET" ] } }, Cmd.none ), NoOp )


goToConfig : Seedbox -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
goToConfig seedbox model =
    case model.state of
        ConfigSeedbox ( currentBox, _, _ ) ->
            if currentBox == seedbox then
                ( ( model, Cmd.none ), NoOp )
            else
                ( ( { model | state = ConfigSeedbox ( seedbox, pendingFromSeedbox seedbox, RemoteData.NotAsked ) }, Cmd.none ), NoOp )

        _ ->
            ( ( { model | state = ConfigSeedbox ( seedbox, pendingFromSeedbox seedbox, RemoteData.NotAsked ) }, Cmd.none ), NoOp )


input : (String -> RemoteField) -> String -> Msg
input field value =
    Input (field value)


applyInput : State -> RemoteField -> State
applyInput state field =
    let
        applyWithLens lens value =
            state
                |> (lens.set value
                        |> Lens.modify pendingSeedboxOfState
                   )
    in
        case field of
            Host host ->
                applyWithLens Data.hostOfBox host

            Name name ->
                applyWithLens Data.nameOfBox name

            Port port_ ->
                applyWithLens Data.portOfBox port_

            AuthName authName ->
                let
                    lens =
                        let
                            optionalAuthOfBox =
                                Optional.fromLens Data.authOfBox
                        in
                            Optional.compose optionalAuthOfBox Data.userNameOfAuth
                in
                    applyWithLens lens authName

            AuthPassword password ->
                let
                    lens =
                        let
                            optionalAuthOfBox =
                                Optional.fromLens Data.authOfBox
                        in
                            Optional.compose optionalAuthOfBox Data.passwordOfAuth
                in
                    applyWithLens lens password


toggleAuth : Model -> Model
toggleAuth =
    Lens.modify stateOfModel (Lens.modify pendingSeedboxOfState Data.toggleAuth)


verifySeedbox : PendingSeedbox -> Result Errors { auth : Data.Auth, host : String, name : String, port_ : Int }
verifySeedbox pendingSeedbox =
    String.toInt pendingSeedbox.port_
        |> Result.map
            (\port_ ->
                ({ host = pendingSeedbox.host, name = pendingSeedbox.name, port_ = port_, auth = pendingSeedbox.auth })
            )
        |> Result.mapError (\_ -> { errors | port_ = [ "Error parsing port to an int" ] })


pushSeedbox : Model -> ( Model, Cmd Msg )
pushSeedbox model =
    case model.state of
        AddSeedbox ( pendingSeedbox, _ ) ->
            pendingSeedbox
                |> verifySeedbox
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

        ConfigSeedbox ( seedbox, pendingSeedbox, _ ) ->
            pendingSeedbox
                |> verifySeedbox
                |> (\verified ->
                        case verified of
                            Result.Ok toEncode ->
                                Data.seedboxEncoder toEncode
                                    |> Request.Seedbox.update seedbox
                                    |> sendRequest
                                    |> (\cmd -> ( model |> Lens.modify stateOfModel (seedboxRemoteDataOfState.set RemoteData.Loading), Cmd.map UpdateStatus cmd ))

                            Result.Err errors ->
                                ( errorsOfModel.set errors model, Cmd.none )
                   )


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


handleDeleteStatus : RemoteData Errors String -> Model -> ( Model, Cmd Msg )
handleDeleteStatus remoteData model =
    let
        removeFromList id =
            RemoteData.map (List.filter (\s -> s.id /= id))
    in
        case remoteData of
            RemoteData.Success deletedId ->
                let
                    newModel =
                        case model.state of
                            ConfigSeedbox ( { id }, _, _ ) ->
                                if id == deletedId then
                                    (({ model | state = AddSeedbox ( freshSeedbox, RemoteData.NotAsked ) }))
                                else
                                    (model)

                            _ ->
                                (model)
                in
                    ( { newModel | seedboxes = removeFromList deletedId newModel.seedboxes }, Cmd.none )

            RemoteData.Failure errors ->
                ( { model | errors = errors }, Cmd.none )

            _ ->
                Debug.crash "should not happen"


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


deleteSeedbox : Model -> ( Model, Cmd Msg )
deleteSeedbox model =
    case model.state of
        AddSeedbox _ ->
            ( model, Cmd.none )

        ConfigSeedbox ( box, _, _ ) ->
            box
                |> Request.Seedbox.delete
                |> sendRequest
                |> (\cmd -> ( model, Cmd.map DeleteSeedboxStatus cmd ))


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
