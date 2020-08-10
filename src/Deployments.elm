module Deployments exposing
    ( Deployment
    , init
    , view
    )

import Html exposing (Html, a, button, div, h1, h2, h3, img, li, p, span, text, ul)
import Html.Attributes exposing (alt, class, href, src, type_)
import Svg exposing (path, svg)
import Svg.Attributes as SvgA exposing (attributeName, color, d, fill, stroke, strokeLinejoin, strokeWidth, viewBox)



-------------------------------
-- Everything related to a deployment
-------------------------------


type alias Deployment =
    { name : String }


init : List Deployment
init =
    [ { name = "test"
      }
    ]



-------------------------------
-- Views
-------------------------------


view : List Deployment -> Html msg
view deployments =
    div [ class "px-4 py-5 sm:p-6" ]
        [ ul [ class "grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3" ]
            (List.map deploymentCard deployments)
        ]


deploymentCard : Deployment -> Html msg
deploymentCard deployment =
    li [ class "col-span-1 bg-white rounded-lg shadow" ]
        [ div [ class "w-full flex items-center justify-between p-6 space-x-6" ]
            [ div [ class "flex-1 truncate" ]
                [ div [ class "flex items-center space-x-3" ]
                    [ h3 [ class "text-gray-900 text-sm leading-5 font-medium truncate" ]
                        [ text "Deployment 1" ]
                    , span [ class "flex-shrink-0 inline-block px-2 py-0.5 text-teal-800 text-xs leading-4 font-medium bg-teal-100 rounded-full" ]
                        [ text "https://huge-old-flat-king.fission.app/" ]
                    ]
                , p [ class "mt-1 text-gray-500 text-sm leading-5 truncate" ]
                    [ text "Deployment size: 5mb" ]
                ]
            ]
        , div [ class "border-t border-gray-200" ]
            [ div [ class "-mt-px flex" ]
                [ div [ class "w-0 flex-1 flex border-r border-gray-200" ]
                    [ a [ class "relative -mr-px w-0 flex-1 inline-flex items-center justify-center py-4 text-sm leading-5 text-gray-700 font-medium border border-transparent rounded-bl-lg hover:text-gray-500 focus:outline-none focus:shadow-outline-blue focus:border-blue-300 focus:z-10 transition ease-in-out duration-150", href "#" ]
                        [ svg [ SvgA.class "w-5 h-5 text-gray-400", viewBox "0 0 24 24" ]
                            [ path [ d "M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9", stroke "round", strokeLinejoin "round", strokeWidth "2" ]
                                []
                            ]
                        , span [ class "ml-3" ]
                            [ text
                                "Visit"
                            ]
                        ]
                    ]
                ]
            ]
        ]
