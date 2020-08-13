module User exposing (User(..), guestView)

import Browser
import Constants
import Html exposing (Html, a, button, div, h1, h2, h3, img, li, p, span, text, ul)
import Html.Attributes exposing (alt, class, href, src, type_)
import Svg exposing (path, svg)
import Svg.Attributes as SvgA exposing (attributeName, color, d, fill, stroke, strokeLinejoin, strokeWidth, viewBox)


type User
    = Guest
    | User String


guestView : Html msg
guestView =
    -- really the unauthed or homescreen
    div [ class "flex flex-col text-lg items-center " ]
        [ h1 [ class "text-2xl " ]
            [ text "Login to view all your deployments" ]
        , button [ class "w-40  bg-indigo-500 hover:bg-blue-700 text-white font-bold mt-4 py-2 px-4 rounded" ] [ text "Login" ]
        ]
