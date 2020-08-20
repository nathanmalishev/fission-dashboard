port module Ports exposing (..)

import AssocList as Dict exposing (Dict)
import Deployment exposing (DeleteState, Deployment, Key)
import Dict as StandardDict
import Json.Decode as Decode exposing (Decoder, Value, decodeValue, dict, field, index, map, map2, string)



-- send


port fetchDeployments : () -> Cmd msg


port delete : { key : String, subdomain : String } -> Cmd msg


port login : () -> Cmd msg


port create : () -> Cmd msg



-- recieve


port recieveDeployments : (Value -> msg) -> Sub msg


port deleteDeployment : (Value -> msg) -> Sub msg


port createDeployment : (Value -> msg) -> Sub msg



-------------------------------
-- Decoders
-------------------------------


type Error
    = Unkown Value
    | Network DeleteError


createDecoder : Value -> Result Error String
createDecoder json =
    case decodeValue string json of
        Ok subdomain ->
            Ok subdomain

        Err _ ->
            case decodeValue deleteErrorDecoder json of
                Ok error ->
                    Err (Network error)

                Err _ ->
                    Err (Unkown json)


type alias DeleteError =
    { key : String
    , err : String
    }


deleteDecoder : Value -> Result Error String
deleteDecoder json =
    case decodeValue string json of
        Ok message ->
            Ok message

        Err _ ->
            case decodeValue deleteErrorDecoder json of
                Ok error ->
                    Err (Network error)

                Err _ ->
                    Err (Unkown json)


deleteErrorDecoder : Decoder DeleteError
deleteErrorDecoder =
    map2 DeleteError
        (field "key" string)
        (field "err" string)


decoderDeployment : Decoder String
decoderDeployment =
    index 0 string


dictToDeployments : StandardDict.Dict String String -> Dict Key Deployment
dictToDeployments dict =
    dict
        |> StandardDict.toList
        |> List.map (\( k, v ) -> ( Deployment.stringToKey k, Deployment v Deployment.NotAsked Nothing ))
        |> Dict.fromList


decoderDeployments2 : Decoder (Dict Key Deployment)
decoderDeployments2 =
    map dictToDeployments <|
        dict decoderDeployment
