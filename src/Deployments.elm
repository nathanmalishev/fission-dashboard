module Deployments exposing
    ( Deployment
    , init
    , view
    )

import Html exposing (Html, a, button, div, h1, h2, h3, img, li, p, span, text, ul)
import Html.Attributes exposing (alt, class, href, src, target, type_)
import Svg exposing (path, svg)
import Svg.Attributes as SvgA exposing (attributeName, color, d, fill, stroke, strokeLinejoin, strokeWidth, viewBox)



-------------------------------
-- Everything related to a deployment
-------------------------------


type alias Deployment =
    { subdomain : String
    , size : String -- not sure if i can get this stat easily just leaving as string for the moment as it might be deleted
    }


init : List Deployment
init =
    [ { subdomain = "huge-old-flat-king.fission.app"
      , size = "5mb"
      }
    , { subdomain = "small-old-flat-king.fission.app"
      , size = "10mb"
      }
    ]



-------------------------------
-- Views
-------------------------------


view : List Deployment -> String -> Html msg
view deployments username =
    div [ class "px-0 md:px-4 py-5 sm:p-6 mb-4 justify-center flex" ]
        [ ul [ class "flex flex-wrap mb-4 md:w-1/2 w-full" ]
            (List.map deploymentCard deployments)
        ]


deploymentCard : Deployment -> Html msg
deploymentCard deployment =
    li [ class "w-full flex mb-8 bg-white rounded-lg shadow-md " ]
        [ div [ class "w-full flex items-center justify-between" ]
            [ div [ class "flex flex-col px-2 md:px-8 py-4" ]
                [ div [ class "flex items-center space-x-3" ]
                    [ h3 [ class "text-gray-900 text-lg leading-5 font-medium truncate text-teal-800" ]
                        [ text deployment.subdomain ]

                    --, span [ class "flex-shrink-0 inline-block px-2 py-0.5 text-teal-800 text-lg leading-4 font-medium bg-teal-100 rounded-full" ]
                    --[ text deployment.subdomain ]
                    ]
                , p [ class "flex justify-start mt-1 text-gray-500 text-s  runcate" ]
                    [ text ("Deployment size: " ++ deployment.size) ]

                -- buttons below
                , div
                    [ class "flex flex-col px-0 pt-4 md:flex-row " ]
                    [ a [ class "flex mx-2 md:w-1/2 w-1/2 h-8 shadow-md hover:bg-red-200 text-red-500 font-bold my-1 md:my-0 md:py-0 px-2 rounded-full", href "#" ]
                        [ span [ class "flex items-center " ]
                            [ h3 [ class "m-2" ]
                                [ text
                                    "Delete"
                                ]
                            , svg [ SvgA.class "w-5 h-5 text-red-400 ", viewBox "0 0 24 24" ]
                                [ path [ d "M6 18L18 6M6 6L18 18", stroke "#f56565", strokeLinejoin "round", strokeWidth "2", fill "white" ]
                                    []
                                ]
                            ]
                        ]
                    , a [ class "flex mx-2 w-3/4 md:w-full h-8 shadow-md text-indigo-400 hover:bg-indigo-200 font-bold my-1 md:my-0 md:py-0 px-2 rounded-full", href <| "https://drive.fission.codes/#/" ++ deployment.subdomain, target "_blank" ]
                        [ span [ class "flex items-center " ]
                            [ h3 [ class "m-2" ]
                                [ text
                                    "Explore Files"
                                ]
                            , svg [ SvgA.class "w-5 h-5 text-gray-400 ", viewBox "0 0 24 24" ]
                                [ path [ d "M10 21H17C18.1046 21 19 20.1046 19 19V9.41421C19 9.149 18.8946 8.89464 18.7071 8.70711L13.2929 3.29289C13.1054 3.10536 12.851 3 12.5858 3H7C5.89543 3 5 3.89543 5 5V16M5 21L9.87868 16.1213M9.87868 16.1213C10.4216 16.6642 11.1716 17 12 17C13.6569 17 15 15.6569 15 14C15 12.3431 13.6569 11 12 11C10.3431 11 9 12.3431 9 14C9 14.8284 9.33579 15.5784 9.87868 16.1213Z", stroke "#7f9cf5", strokeLinejoin "round", strokeWidth "2", fill "white" ]
                                    []
                                ]
                            ]
                        ]
                    ]
                ]

            -- End button
            , a [ class "hover:underline text-teal-400 border-l border-gray-200 md:border-l md:border-0", href "#" ]
                [ div [ class "px-8 py-8 flex " ]
                    [ span [ class "flex items-center " ]
                        [ h3 [ class "m-2 text-teal-400  text-xl" ]
                            [ text
                                "Visit"
                            ]
                        , svg [ SvgA.class "w-5 h-5 ", viewBox "0 0 24 24" ]
                            [ path [ d "M10 6H6C4.89543 6 4 6.89543 4 8V18C4 19.1046 4.89543 20 6 20H16C17.1046 20 18 19.1046 18 18V14M14 4H20M20 4V10M20 4L10 14", stroke "#4fd1c5", strokeLinejoin "round", strokeWidth "2", fill "white" ]
                                []
                            ]
                        ]
                    ]
                ]
            ]
        ]
