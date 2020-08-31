port module Ports exposing (..)

import AssocList as Dict exposing (Dict)
import Deployment exposing (DeleteState, Deployment, Key)
import Dict as StandardDict
import Json.Decode as Decode
    exposing
        ( Decoder
        , Value
        , decodeValue
        , dict
        , errorToString
        , field
        , map
        , map2
        , string
        )
import Json.Encode as Encode exposing (encode)
import RemoteData exposing (RemoteData)



-- send


port fetchDeployments : () -> Cmd msg


port delete : { key : String, subdomain : String } -> Cmd msg


port login : () -> Cmd msg


port create : () -> Cmd msg


port save : Value -> Cmd msg



-- recieve


port recieveDeployments : (Value -> msg) -> Sub msg


port deleteDeployment : (Value -> msg) -> Sub msg


port createDeployment : (Value -> msg) -> Sub msg


port recieveUsername : (Value -> msg) -> Sub msg



-------------------------------
-- Types
-------------------------------


type Error
    = Unkown Value
    | Network DeleteError


errorToString : Error -> String
errorToString _ =
    -- In the future we may want to provide a specific error
    "Sorry we couldn't seem to fetch your deployments right now."


type alias DeleteError =
    { key : String
    , err : String
    }



-------------------------------
-- Json -> elm
-------------------------------


decodeUsername : Value -> Result Error (Maybe String)
decodeUsername json =
    let
        username =
            Decode.maybe (field "username" string)
    in
    case decodeValue username json of
        Ok message ->
            -- We can get a Nothing here, if username is null
            Ok message

        Err _ ->
            decodeError json


decodeError : Value -> Result Error a
decodeError json =
    case decodeValue deleteErrorDecoder json of
        Ok error ->
            Err (Network error)

        Err _ ->
            Err (Unkown json)


resultDecoder : Value -> Result Error String
resultDecoder json =
    case decodeValue string json of
        Ok message ->
            Ok message

        Err _ ->
            decodeError json


dictToDeployments : StandardDict.Dict String Deployment -> Dict Key Deployment
dictToDeployments dict =
    dict
        |> StandardDict.toList
        |> List.map (\( k, v ) -> ( Deployment.stringToKey k, v ))
        |> Dict.fromList


deploymentsDecoder : Value -> RemoteData Error (Dict Key Deployment)
deploymentsDecoder json =
    let
        deplomentsDecoder =
            map dictToDeployments <|
                dict decoderDeployment
    in
    case decodeValue deplomentsDecoder json of
        Ok values ->
            RemoteData.Success values

        Err _ ->
            case decodeValue deleteErrorDecoder json of
                Ok error ->
                    RemoteData.Failure (Network error)

                Err _ ->
                    RemoteData.Failure (Unkown json)



-------------------------------
-- Decoders
-------------------------------


deleteErrorDecoder : Decoder DeleteError
deleteErrorDecoder =
    Decode.map2 DeleteError
        (field "key" string)
        (field "err" string)


decoderDeployment : Decoder Deployment
decoderDeployment =
    Decode.map3 Deployment
        (field "subdomain" string)
        (field "nickName" (Decode.maybe string))
        (Decode.succeed Deployment.NotAsked)



-------------------------------
-- Elm -> Json
-------------------------------


deploymentsToValue : Dict Key Deployment -> Value
deploymentsToValue deployments =
    deployments
        -- Convert AssocListDict -> Dict
        |> Dict.foldl
            (\k v acc ->
                StandardDict.insert (Deployment.keyToString k) v acc
            )
            StandardDict.empty
        -- Regular Dict we can enocde
        |> Encode.dict
            (\k -> k)
            (\v ->
                Encode.object
                    [ ( "subdomain", Encode.string v.subdomain )
                    , ( "nickName"
                      , case v.nickName of
                            Just name ->
                                Encode.string name

                            Nothing ->
                                Encode.null
                      )
                    ]
            )
