module Data.Seedbox exposing (Auth(..), Seedbox, authOfBox, hostOfBox, passwordOfAuth, portOfBox, seedboxDecoder, seedboxListDecoder, seedboxEncoder, toggleAuth, userNameOfAuth)

import Json.Encode as Encode
import Json.Decode as Decode exposing (andThen, bool, int, fail, field, list, nullable, string)
import Json.Decode.Pipeline exposing (decode, hardcoded, required)
import Monocle.Lens as Lens exposing (Lens)
import Monocle.Optional as Optional exposing (Optional)


type alias Seedbox =
    { accessible : Bool
    , auth : Auth
    , host : String
    , id : String
    , name : String
    , port_ : Int
    }


type alias UserName =
    String


type alias Password =
    String


type Auth
    = NoAuth
    | BasicAuth ( UserName, Password )


seedboxListDecoder : Decode.Decoder (List Seedbox)
seedboxListDecoder =
    list seedboxDecoder


seedboxDecoder : Decode.Decoder Seedbox
seedboxDecoder =
    decode Seedbox
        |> required "accessible" bool
        |> hardcoded NoAuth
        |> required "host" string
        |> required "id" string
        |> required "name" string
        |> required "port" int


seedboxEncoder : { b | host : String, name : String, port_ : Int, auth : Auth } -> Encode.Value
seedboxEncoder box =
    let
        encodedAuth =
            case box.auth of
                NoAuth ->
                    []

                BasicAuth ( n, pw ) ->
                    let
                        authObject =
                            Encode.object [ ( "username", Encode.string n ), ( "password", Encode.string pw ) ]
                    in
                        [ ( "auth", authObject ) ]

        encodedSeedbox =
            Encode.object (encodedAuth ++ [ ( "host", Encode.string box.host ), ( "name", Encode.string box.name ), ( "port", Encode.int box.port_ ) ])
    in
        Encode.object [ ( "seedbox", encodedSeedbox ) ]


hostOfBox : Lens { b | host : String } String
hostOfBox =
    Lens .host (\h b -> { b | host = h })


portOfBox : Lens { b | port_ : p } p
portOfBox =
    Lens .port_ (\h b -> { b | port_ = h })


authOfBox : Lens { box | auth : Auth } Auth
authOfBox =
    Lens .auth (\a b -> { b | auth = a })


userNameOfAuth : Optional Auth UserName
userNameOfAuth =
    Optional
        (\auth ->
            case auth of
                BasicAuth ( n, _ ) ->
                    Just n

                _ ->
                    Nothing
        )
        (\n auth ->
            case auth of
                BasicAuth ( _, pw ) ->
                    BasicAuth ( n, pw )

                _ ->
                    auth
        )


passwordOfAuth : Optional Auth Password
passwordOfAuth =
    Optional
        (\auth ->
            case auth of
                BasicAuth ( _, pw ) ->
                    Just pw

                _ ->
                    Nothing
        )
        (\pw auth ->
            case auth of
                BasicAuth ( n, _ ) ->
                    BasicAuth ( n, pw )

                _ ->
                    auth
        )


toggleAuth : { box | auth : Auth } -> { box | auth : Auth }
toggleAuth =
    let
        oppose auth =
            case auth of
                NoAuth ->
                    BasicAuth ( "", "" )

                _ ->
                    NoAuth
    in
        Lens.modify authOfBox oppose


id : Seedbox -> String
id =
    .id
