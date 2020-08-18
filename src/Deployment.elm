module Deployment exposing
    ( DeleteState(..)
    , Deployment
    , Key
    , card
    , keyToString
    , stringToKey
    )

import Constants
import Html exposing (Html, a, button, div, h1, h2, h3, img, li, p, span, text, ul)
import Html.Attributes exposing (alt, attribute, class, href, id, src, style, target, type_)
import Html.Events exposing (onClick)


type Key
    = Key String


type alias Deployment =
    { subdomain : String

    --, size : String -- not sure if i can get this stat easily just leaving as string for the moment as it might be deleted
    -- meta data
    , delete : DeleteState
    }


type DeleteState
    = NotAsked
    | Deleting
    | Error String


keyToString : Key -> String
keyToString (Key k) =
    k


stringToKey : String -> Key
stringToKey s =
    Key s



-------------------------------
-- views
-------------------------------


card : (( Key, Deployment ) -> msg) -> ( Key, Deployment ) -> Html msg
card openDeleteModalMsg ( key, deployment ) =
    let
        deleteSVG =
            case deployment.delete of
                Deleting ->
                    div [ class "h-4 w-4" ] [ Constants.spinner ]

                _ ->
                    div [ class "h-5 w-5" ] [ Constants.cross ]

        deleteError =
            case deployment.delete of
                Error _ ->
                    div [ class "px-4 flex flex-row w-full items-center content-center pt-4" ]
                        [ div [ class "h-5 w-5" ] [ Constants.exclamation "red" ]
                        , div
                            [ class "px-1 text-blue-900"
                            ]
                            [ text "Something went wrong deleting this app, please try again later" ]
                        ]

                _ ->
                    div [] []
    in
    li [ class "h-40 flex mb-8 rounded-lg shadow w-full", style "background-color" Constants.deploymentCardBackgroundColor ]
        [ div [ class "w-full flex items-center justify-between" ]
            [ div [ class "flex flex-col px-4 md:w-full" ]
                [ div [ class "flex items-center space-x-3 px-2 " ]
                    [ h3 [ class "text-blue-900 text-lg leading-5 font-medium truncate text-teal-800" ]
                        [ text deployment.subdomain ]
                    ]
                , p [ class "flex justify-start mt-1 text-gray-500 px-2 text-s " ]
                    [ text ("Deployment size: " ++ "10mb") ]

                --deployment.size) ]
                -- buttons below
                , div
                    [ class "flex flex-col px-0 pt-4 md:flex-row md:w-8/12 " ]
                    [ a
                        [ class "flex mx-2 md:w-32  justify-center w-1/2 h-8 bg-white shadow-md hover:bg-red-200 text-red-500 font-bold my-1 md:my-0 md:py-0 px-2 rounded-full"
                        , href "#"
                        , onClick (openDeleteModalMsg ( key, deployment ))
                        ]
                        [ span [ class "flex items-center justify-center" ]
                            [ h3 [ class "m-1" ]
                                [ text "Delete"
                                ]
                            , deleteSVG
                            ]
                        ]
                    , a
                        [ class "flex mx-2 w-3/4 md:w-40 justify-center h-8 shadow-md bg-white text-indigo-400 hover:bg-indigo-200 font-bold my-1 md:my-0 md:py-0 px-2 rounded-full"
                        , href <| "https://drive.fission.codes/#/" ++ deployment.subdomain
                        , target "_blank"
                        ]
                        [ span [ class "flex items-center " ]
                            [ h3 [ class "m-2" ]
                                [ text
                                    "Explore Files"
                                ]
                            , Constants.explore
                            ]
                        ]
                    ]

                -- Error info
                , deleteError
                ]

            -- End `visit` button
            , a
                [ class "hover:underline border-l border-gray-200 md:border-l md:border-0"
                , href ("https://" ++ deployment.subdomain)
                , style "color" Constants.visitButtonColor
                , target "_blank"
                ]
                [ div [ class "px-8 py-8 flex " ]
                    [ span [ class "flex items-center " ]
                        [ h3 [ class "m-2 text-xl", style "color" Constants.visitButtonColor ]
                            [ text
                                "Visit"
                            ]
                        , Constants.visit
                        ]
                    ]
                ]
            ]
        ]
