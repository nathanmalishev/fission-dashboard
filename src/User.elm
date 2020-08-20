module User exposing (User(..), guestView, welcomeTab)

import Browser
import Constants
import Html exposing (Html, a, button, div, h1, h2, h3, img, li, p, span, text, ul)
import Html.Attributes exposing (alt, class, href, src, style, type_)
import Html.Events exposing (onClick, onMouseOver)
import Svg exposing (path, svg)
import Svg.Attributes as SvgA exposing (attributeName, color, d, fill, stroke, strokeLinejoin, strokeWidth, viewBox)


type User
    = Guest
    | User String


guestView : msg -> Html msg
guestView login =
    -- tried to make this but..
    div [ class "items-center justify-center flex flex-grow" ]
        [ -- really the unauthed or homescreen
          div [ class "flex flex-col text-lg items-center " ]
            [ h1 [ class "italic text-2xl text-gray-700" ]
                [ text "Login to view all your deployments" ]
            , button
                [ class "w-40 shadow text-white font-bold mt-4 py-2 px-4 rounded"

                -- we lose bg:hover for some random reason when using a custom background-color
                -- but it looks way better this way. The fix is changing the `tailwind.config.js`
                , style "background-color" "#909dfb"
                , Html.Events.onClick login
                ]
                [ text "Login" ]
            ]
        ]


welcomeTab : String -> Int -> msg -> Bool -> Html msg
welcomeTab username deploymentCount createNewDeployment creatingDeployment =
    div [ class "px-0 py-0 py-2 mb-6 flex-col flex md:w-3/4 xl:w-1/2 w-full sm:w-full self-center " ]
        [ div [ class "flex flex-row border-b border-indigo-200 justify-between" ]
            [ h3 [ class "text-lg text-blue-900" ]
                [ text ("Welcome " ++ username)
                ]
            , button [ class "flex flex-row text-lg focus:outline-none text-blue-900", onClick createNewDeployment ]
                [ text "Create new"
                , if creatingDeployment then
                    div [ class "h-5 w-5" ] [ Constants.spinner ]

                  else
                    div [ class "w-5" ] []
                ]
            ]
        , div
            [ class "text-left" ]
            [ h3
                [ class "text-gray-500" ]
                [ text (String.fromInt deploymentCount ++ " deployments")
                ]
            ]
        ]
