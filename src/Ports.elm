port module Ports exposing (..)

import AssocList as Dict exposing (Dict)
import Deployment exposing (DeleteState, Deployment, Key)
import Dict as StandardDict
import Json.Decode as Decode exposing (field, map2, string)



-- send


port getDeployments : () -> Cmd msg


port delete : { key : String, subdomain : String } -> Cmd msg


port login : () -> Cmd msg



-- recieve


port recieveDeployments : (Decode.Value -> msg) -> Sub msg



-- FIXME roll deleteDeployment into one


port deleteDeploymentSuccess : (String -> msg) -> Sub msg


port deleteDeploymentFailure : ({ key : String, err : String } -> msg) -> Sub msg



-------------------------------
-- Deocders
-------------------------------


decoderDeployment : Decode.Decoder String
decoderDeployment =
    Decode.index 0 string


dictToDeployments : StandardDict.Dict String String -> Dict Key Deployment
dictToDeployments dict =
    dict
        |> StandardDict.toList
        |> List.map (\( k, v ) -> ( Deployment.stringToKey k, Deployment v Deployment.NotAsked ))
        |> Dict.fromList


decoderDeployments2 : Decode.Decoder (Dict Key Deployment)
decoderDeployments2 =
    Decode.map dictToDeployments <|
        Decode.dict decoderDeployment

