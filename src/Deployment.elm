module Deployment exposing
    ( DeleteState(..)
    , Deployment
    , Key
    , add
    , card
    , delete
    , keyToString
    , new
    , setDeleteState
    , stringToKey
    , updateNickName
    )

import AssocList as Dict exposing (Dict)
import Constants
import Html exposing (Html, a, button, div, h1, h2, h3, img, input, li, p, span, text, ul)
import Html.Attributes exposing (alt, attribute, class, href, id, property, src, style, target, type_, value)
import Html.Events exposing (on, onClick, onInput)


type Key
    = Key String


type alias Deployment =
    { subdomain : String
    , nickName : Maybe String
    , delete : DeleteState

    -- Future ideas 💡
    -- -> Size of deployment
    -- -> Custom domain
    -- -> Last date deployed
    }


type DeleteState
    = NotAsked
    | Deleting
    | Error String



-- helpers


keyToString : Key -> String
keyToString (Key k) =
    k


stringToKey : String -> Key
stringToKey s =
    Key s


new : String -> Deployment
new subdomain =
    { subdomain = subdomain
    , delete = NotAsked
    , nickName = Nothing
    }


updateNickName : Key -> String -> Dict Key Deployment -> Dict Key Deployment
updateNickName key newNick deployments =
    Dict.update key (Maybe.map (\maybeV -> { maybeV | nickName = Just newNick })) deployments


delete : Key -> Dict Key Deployment -> Dict Key Deployment
delete givenKey deployments =
    Dict.update givenKey (\_ -> Nothing) deployments


setDeleteState : Key -> DeleteState -> Dict Key Deployment -> Dict Key Deployment
setDeleteState key state deployments =
    Dict.update key (Maybe.map (\v -> { v | delete = state })) deployments


add : Key -> Deployment -> Dict Key Deployment -> Dict Key Deployment
add key deployment deployments =
    Dict.insert key deployment deployments



-------------------------------
-- views
-------------------------------


card :
    (( Key, String ) -> msg)
    -> (( Key, Deployment ) -> msg)
    -> ( Key, Deployment )
    -> Html msg
card editNickMsg openDeleteModalMsg ( key, deployment ) =
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
                        [ div [ class "h-5 w-5" ] [ Constants.exclamation ]
                        , div
                            [ class "px-1 text-blue-900"
                            ]
                            [ text "Something went wrong deleting this app, please try again later" ]
                        ]

                _ ->
                    div [] []

        nickName =
            Maybe.withDefault "Add a nickname" deployment.nickName
    in
    li [ class "h-40 flex mb-8 rounded-lg shadow w-full", style "background-color" Constants.deploymentCardBackgroundColor ]
        [ div [ class "w-full flex items-center justify-between md:w-3/4 lg:w-full" ]
            [ div [ class "flex flex-col px-2 sm:px-4 md:w-full w-3/4" ]
                [ div [ class "flex items-center space-x-3 md:px-2 w-full px-0" ]
                    [ h3 [ class "px-2 md:px-0 text-blue-900 lg:text-lg text-sm sm:text-base leading-5 font-medium truncate text-teal-800" ]
                        [ text deployment.subdomain ]
                    ]

                -- nickname el
                , div [ class "flex" ]
                    [ div [ class "flex flex-row flex-shrink justify-start text-sm sm:text-base mt-1 text-gray-500 px-2 lg:text-base items-center focus:outline-none" ]
                        [ input
                            --⚠️  had to do some hacky stuff to get a text field to grow with the nickname
                            -- Long story short `contenteditable` does not work well with elm - don't even try
                            [ class "  rounded text-indigo-500 max-w-full w-full focus:outline-none"
                            , onInput (\string -> editNickMsg ( key, string ))
                            , style "width" (String.fromInt ((String.length nickName + 2) * 8) ++ "px")
                            , style "background-color" Constants.deploymentCardBackgroundColor
                            , value nickName
                            ]
                            []
                        , div [ class "pl-0" ] [ div [ class "w-4 h-4" ] [ Constants.tag ] ]
                        ]
                    ]

                -- buttons below
                , div
                    [ class "flex flex-col px-0 pt-4 md:flex-row md:w-10/12 " ]
                    [ a
                        [ class "flex w-3/4 sm:w-1/2 mx-2 md:w-56 sm:w-40 justify-center h-8 bg-white shadow-md hover:bg-red-200 text-red-500 font-bold my-1 md:my-0 md:py-0 px-2 rounded-full"
                        , href "#"
                        , onClick (openDeleteModalMsg ( key, deployment ))
                        ]
                        [ span [ class "flex items-center justify-center" ]
                            [ h3 [ class "m-1 text-sm lg:text-lg" ]
                                [ text "Delete"
                                ]
                            , deleteSVG
                            ]
                        ]
                    , a
                        [ class "flex w-3/4 sm:w-1/2 mx-2 sm:w-40 md:w-64 justify-center h-8 shadow-md bg-white text-indigo-400 hover:bg-indigo-200 font-bold my-1 md:my-0 md:py-0 px-2 rounded-full"
                        , href <| "https://drive.fission.codes/#/" ++ deployment.subdomain
                        , target "_blank"
                        ]
                        [ span [ class "flex items-center " ]
                            [ h3 [ class "m-2 text-sm lg:text-lg" ]
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
                [ class "flex hover:underline border-l border-gray-200 md:border-l md:border-0 flex-grow justify-center"
                , href ("https://" ++ deployment.subdomain)
                , style "color" Constants.titleColor
                , target "_blank"
                ]
                [ div [ class " text-center py-8 flex sm:px-8 px-0 " ]
                    [ span [ class "flex items-center " ]
                        [ h3 [ class "m-2 sm:text-base md:text-xl", style "color" Constants.titleColor ]
                            [ text
                                "Visit"
                            ]
                        , Constants.visit
                        ]
                    ]
                ]
            ]
        ]
