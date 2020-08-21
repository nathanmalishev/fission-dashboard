module Constants exposing (..)

import Html exposing (Html)
import Svg exposing (g, path, svg)
import Svg.Attributes as SvgA exposing (class, d, fill, stroke, strokeLinecap, strokeLinejoin, strokeWidth, viewBox)



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


visitButtonColor : String
visitButtonColor =
    -- planned
    titleColor


logoUrl : String
logoUrl =
    "logo.png"



-------------------------------
-- SVGS
-------------------------------


spinner : Html msg
spinner =
    svg [ viewBox "0 0 20 20", class "animate-spin" ]
        [ g []
            [ path
                -- through trial and error theres make the nice circle
                [ d "M1,9 a1,1 0 0,0 18,0"
                , fill "transparent"
                , strokeWidth "3"
                , stroke "#f56565"
                ]
                []
            ]
        ]


cross : Html msg
cross =
    svg [ viewBox "0 0 24 24" ]
        [ path [ d "M6 18L18 6M6 6L18 18", stroke "#f56565", strokeLinejoin "round", strokeWidth "2", fill "white" ]
            []
        ]


explore : Html msg
explore =
    svg [ SvgA.class "w-5 h-5 text-gray-400 ", viewBox "0 0 24 24" ]
        [ path [ d "M10 21H17C18.1046 21 19 20.1046 19 19V9.41421C19 9.149 18.8946 8.89464 18.7071 8.70711L13.2929 3.29289C13.1054 3.10536 12.851 3 12.5858 3H7C5.89543 3 5 3.89543 5 5V16M5 21L9.87868 16.1213M9.87868 16.1213C10.4216 16.6642 11.1716 17 12 17C13.6569 17 15 15.6569 15 14C15 12.3431 13.6569 11 12 11C10.3431 11 9 12.3431 9 14C9 14.8284 9.33579 15.5784 9.87868 16.1213Z", stroke "#7f9cf5", strokeLinejoin "round", strokeWidth "2", fill "white" ]
            []
        ]


visit : Html msg
visit =
    svg [ SvgA.class "w-5 h-5 ", viewBox "0 0 24 24" ]
        [ path [ d "M10 6H6C4.89543 6 4 6.89543 4 8V18C4 19.1046 4.89543 20 6 20H16C17.1046 20 18 19.1046 18 18V14M14 4H20M20 4V10M20 4L10 14", stroke visitButtonColor, strokeLinejoin "round", strokeWidth "2", fill "white" ]
            []
        ]


exclamation : String -> Html msg
exclamation strokeColor =
    svg [ viewBox "0 0 24 24" ]
        [ path [ d "M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z", strokeLinejoin "round", strokeWidth "2", fill "none", stroke strokeColor, strokeLinecap "round" ]
            []
        ]


tag : Html msg
tag =
    svg [ viewBox "0 0 24 24" ]
        [ path [ d "M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z", strokeLinejoin "round", strokeWidth "2", fill "none", stroke "#7f9cf5", strokeLinecap "round" ]
            []
        ]
