module Constants exposing (..)

import Color exposing (Color)
import Html exposing (Html, a, button, div, h2, h3, img, li, p, span, text, ul)
import Html.Attributes as HtmlA exposing (style)
import TypedSvg exposing (animate, circle, g, path, svg)
import TypedSvg.Attributes as SvgA exposing (..)
import TypedSvg.Core as Core
import TypedSvg.Types as SvgT exposing (Transform(..), px)



-------------------------------
-- Colors 🖌️
-------------------------------


titleColor : String
titleColor =
    "#2609b1"


titleBackgroundColor : String
titleBackgroundColor =
    "#f6f7ff"


deploymentCardBackgroundColor : String
deploymentCardBackgroundColor =
    "#fafafd"


deploymentCardButtonBgColor : String
deploymentCardButtonBgColor =
    "white"


visitButtonColor : Color
visitButtonColor =
    -- same as title color
    Color.rgb255 38 9 177


logoUrl : String
logoUrl =
    "logo.png"


deleteRed : Color
deleteRed =
    Color.rgb255 245 101 101


white : Color
white =
    Color.rgb255 255 255 255


transparent : Color
transparent =
    Color.rgba 0 0 0 0


exploreColor : Color
exploreColor =
    Color.rgb255 127 156 245



-------------------------------
-- SVGS
-------------------------------


spinner : Html msg
spinner =
    svg [ viewBox 0 0 20 20, class [ "animate-spin" ] ]
        [ g []
            [ TypedSvg.path
                -- through trial and error theres make the nice circle
                [ d "M1,9 a1,1 0 0,0 18,0"
                , fill (SvgT.Paint transparent)
                , strokeWidth (px 3)
                , stroke (SvgT.Paint deleteRed)
                ]
                []
            ]
        ]


cross : Html msg
cross =
    svg [ viewBox 0 0 24 24 ]
        [ TypedSvg.path
            [ d "M6 18L18 6M6 6L18 18"
            , stroke (SvgT.Paint deleteRed)
            , strokeLinejoin SvgT.StrokeLinejoinRound
            , strokeWidth (px 2)
            , fill (SvgT.Paint transparent)
            ]
            []
        ]


explore : Html msg
explore =
    svg [ SvgA.class [ "w-5 h-5 text-gray-400 " ], viewBox 0 0 24 24 ]
        [ TypedSvg.path
            [ d "M10 21H17C18.1046 21 19 20.1046 19 19V9.41421C19 9.149 18.8946 8.89464 18.7071 8.70711L13.2929 3.29289C13.1054 3.10536 12.851 3 12.5858 3H7C5.89543 3 5 3.89543 5 5V16M5 21L9.87868 16.1213M9.87868 16.1213C10.4216 16.6642 11.1716 17 12 17C13.6569 17 15 15.6569 15 14C15 12.3431 13.6569 11 12 11C10.3431 11 9 12.3431 9 14C9 14.8284 9.33579 15.5784 9.87868 16.1213Z"
            , stroke (SvgT.Paint exploreColor)
            , strokeLinejoin SvgT.StrokeLinejoinRound
            , strokeWidth (px 2)
            , fill (SvgT.Paint white)
            ]
            []
        ]


visit : Html msg
visit =
    svg [ SvgA.class [ "w-5 h-5 " ], viewBox 0 0 24 24 ]
        [ TypedSvg.path
            [ d "M10 6H6C4.89543 6 4 6.89543 4 8V18C4 19.1046 4.89543 20 6 20H16C17.1046 20 18 19.1046 18 18V14M14 4H20M20 4V10M20 4L10 14"
            , stroke (SvgT.Paint visitButtonColor)
            , strokeLinejoin SvgT.StrokeLinejoinRound
            , strokeWidth (px 2)
            , fill (SvgT.Paint white)
            ]
            []
        ]


exclamation : Html msg
exclamation =
    svg [ viewBox 0 0 24 24 ]
        [ TypedSvg.path
            [ d "M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
            , strokeLinejoin SvgT.StrokeLinejoinRound
            , strokeWidth (px 2)
            , fill (SvgT.Paint transparent)
            , stroke (SvgT.Paint deleteRed)
            , strokeLinecap SvgT.StrokeLinecapRound
            ]
            []
        ]


tag : Html msg
tag =
    let
        color =
            Color.rgb255 127 156 245
    in
    svg [ viewBox 0 0 24 24 ]
        [ TypedSvg.path
            [ d "M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"
            , strokeLinejoin SvgT.StrokeLinejoinRound
            , strokeWidth (px 2)
            , fill (SvgT.Paint transparent)
            , stroke (SvgT.Paint color)
            , strokeLinecap SvgT.StrokeLinecapRound
            ]
            []
        ]


spinnerSvg : Html msg
spinnerSvg =
    svg [ viewBox 0 0 40 40 ]
        [ g [ transform [ Translate 2 2 ] ]
            [ circle
                [ cx (px 18)
                , cy (px 18)
                , r (px 18)
                , SvgA.stroke (SvgT.Paint visitButtonColor)
                , SvgA.fill (SvgT.Paint transparent)
                , strokeWidth (px 3)
                , strokeOpacity (SvgT.Opacity 0.5)
                ]
                []
            , TypedSvg.path
                [ d "M36 18c0-9.94-8.06-18-18-18"
                , SvgA.stroke (SvgT.Paint visitButtonColor)
                , SvgA.fill (SvgT.Paint transparent)
                , strokeWidth (px 3)
                ]
                [ TypedSvg.animateTransform
                    [ SvgA.from3 0 18 18
                    , SvgA.to3 360 18 18
                    , SvgA.dur (SvgT.Duration "1s")
                    , SvgA.repeatCount SvgT.RepeatIndefinite
                    , SvgA.animateTransformType SvgT.AnimateTransformTypeRotate
                    , SvgA.attributeName "transform"
                    ]
                    []
                ]
            ]
        ]



-------------------------------
-- Views
-------------------------------


loading : Html msg
loading =
    div [ HtmlA.class "flex flex-grow items-center self-center" ]
        [ div [ HtmlA.class "w-8 h-8 " ] [ spinnerSvg ]
        ]
