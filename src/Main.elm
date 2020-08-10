module Main exposing (..)

import Browser
import Deployments exposing (Deployment)
import Html exposing (Html, a, button, div, h1, h2, h3, img, li, p, span, text, ul)
import Html.Attributes exposing (alt, class, href, src, type_)
import Svg exposing (path, svg)
import Svg.Attributes as SvgA exposing (attributeName, color, d, fill, stroke, strokeLinejoin, strokeWidth, viewBox)



---- MODEL ----


type alias Model =
    { deployments : List Deployment
    }


init : ( Model, Cmd Msg )
init =
    ( { deployments = Deployments.init
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div [ class "bg-white overflow-hidden shadow rounded-lg" ]
        -- title
        [ div [ class "border-b border-gray-200 px-4 py-5 sm:px-6" ]
            [ div [ class "md:flex md:items-center md:justify-between" ]
                [ div [ class "flex-1 min-w-0" ]
                    [ h2 [ class "text-2xl font-bold leading-7 text-grey-900 sm:text-3xl sm:leading-9 sm:truncate" ]
                        [ text "Deployments" ]
                    ]
                ]
            ]

        -- content
        , Deployments.view model.deployments

        -- Footer
        , div [ class "border-t border-gray-200 px-4 py-4 sm:px-6" ]
            [ text "    "
            , text "  "
            ]
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
