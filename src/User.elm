module User exposing (User(..), guestView)

import Browser
import Constants
import Deployments exposing (Deployment)
import Html exposing (Html, a, button, div, h1, h2, h3, img, li, p, span, text, ul)
import Html.Attributes exposing (alt, class, href, src, type_)
import Svg exposing (path, svg)
import Svg.Attributes as SvgA exposing (attributeName, color, d, fill, stroke, strokeLinejoin, strokeWidth, viewBox)


type User
    = Guest
    | User String


guestView : Html msg
guestView =
    div [ class "bg-white overflow-hidden shadow rounded-lg" ]
        -- title
        [ div [ class "flex flex-row justify-center items-center" ]
            [ img [ src Constants.logoUrl, class "h-12 m-4" ]
                []
            , h2 [ class "text-2xl font-bold leading-7 text-grey-900 sm:text-3xl sm:leading-9 sm:truncate" ]
                [ text "Fission Deployments"
                ]
            ]
        ]
