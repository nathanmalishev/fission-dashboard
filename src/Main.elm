module Main exposing (..)

import Browser
import Constants
import Html exposing (Html, a, button, div, h1, h2, h3, img, li, p, span, text, ul)
import Html.Attributes exposing (alt, attribute, class, href, id, src, style, target, type_)
import Html.Events exposing (onClick)
import Http
import RemoteData exposing (RemoteData)
import Svg exposing (path, svg)
import Svg.Attributes as SvgA exposing (attributeName, color, d, fill, stroke, strokeLinejoin, strokeWidth, viewBox)
import User exposing (User)



---- MODEL ----


type alias Model =
    { deployments : RemoteData Http.Error (List Deployment)
    , user : User
    , deleteModal : ModalState
    , error : Maybe Http.Error
    }


type ModalState
    = Open Deployment
    | Closed


type alias Deployment =
    { subdomain : String
    , size : String -- not sure if i can get this stat easily just leaving as string for the moment as it might be deleted
    }


successMock : Model
successMock =
    { deployments =
        RemoteData.Success
            [ { subdomain = "huge-old-flat-king.fission.app"
              , size = "5mb"
              }
            , { subdomain = "small-old-flat-king.fission.app"
              , size = "10mb"
              }
            ]
    , user = User.User "nathan"
    , deleteModal = Closed
    , error = Nothing
    }


errorMock : Model
errorMock =
    { deployments = RemoteData.Failure Http.Timeout
    , user = User.User "nathan"
    , deleteModal = Closed
    , error = Nothing
    }


loadingMock : Model
loadingMock =
    { deployments = RemoteData.Loading
    , user = User.User "nathan"
    , deleteModal = Closed
    , error = Nothing
    }


guestMock : Model
guestMock =
    { deployments = RemoteData.Loading
    , user = User.Guest
    , deleteModal = Closed
    , error = Nothing
    }


init : ( Model, Cmd Msg )
init =
    -- FIXME add flags
    ( guestMock
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = OpenDeleteModal Deployment
    | CloseDeleteModal
    | DeleteDeployment Deployment
    | OnCompletedDeleteDeployment (RemoteData Http.Error String)
    | OnCompletedFetchDeployments (List Deployment)
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OpenDeleteModal deployment ->
            ( { model | deleteModal = Open deployment }, Cmd.none )

        CloseDeleteModal ->
            ( { model | deleteModal = Closed }, Cmd.none )

        DeleteDeployment deployment ->
            -- FIXME Ask port to ask sdk to delete deployment
            Debug.todo "DeleteDeployment"

        OnCompletedDeleteDeployment response ->
            -- FIXME not sure how the data will come through the port .. Leave this too later
            Debug.todo "OnCompletedDeleteDeployment"

        OnCompletedFetchDeployments deployments ->
            -- FIXME -- we fetched deployments from our port?
            Debug.todo "OnCompletedFetchDeployments"

        NoOp ->
            ( model, Cmd.none )



---- HELPERS -----


deleteDeployment : String -> List Deployment -> List Deployment
deleteDeployment subdomain deployments =
    List.filter (\d -> d.subdomain /= subdomain) deployments


httpErrorToString : Http.Error -> String
httpErrorToString error =
    -- In the future we may want to provide a specific error
    "Sorry we couldn't seem to fetch your deployments right now."



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        content =
            -- auth check
            case model.user of
                User.User username ->
                    case model.deployments of
                        -- data state check
                        RemoteData.Success deployments ->
                            deploymentsView model.deleteModal deployments username

                        RemoteData.NotAsked ->
                            Debug.todo "ask javascript for data"

                        RemoteData.Loading ->
                            -- FIXME may experience some flasing without a delay to loading
                            -- or a forced look at this loading for at least a second
                            loading

                        RemoteData.Failure e ->
                            httpErrorToString e
                                |> errorView

                User.Guest ->
                    User.guestView
    in
    div [ class "min-h-screen bg-white overflow-hidden shadow rounded-lg flex flex-col " ]
        -----------
        -- title --
        -----------
        [ div [ class "flex px-4 py-5 sm:px-6 justify-center", style "background-color" Constants.titleBackgroundColor ]
            [ div [ class "flex flex-row justify-center items-center" ]
                [ img [ src Constants.logoUrl, class "h-12 m-4" ]
                    []
                , h2 [ class "text-2xl font-bold leading-7  sm:text-3xl sm:leading-9 sm:truncate ", style "color" Constants.titleColor ]
                    [ text "Fission Deployments"
                    ]
                ]
            ]

        -- content
        , content

        -- Footer
        , div [ class "flex px-4 py-4 sm:px-6", style "background-color" Constants.titleBackgroundColor ]
            [ text "    "
            , text "  "
            ]
        ]


loading : Html msg
loading =
    let
        loadingComponent =
            div
                [ class "shadow rounded-md p-4 md:w-1/2 w-full mx-auto py-5 mb-4 h-32"
                , style "background-color" Constants.deploymentCardBackgroundColor
                ]
                [ div [ class "animate-pulse flex space-x-4" ]
                    [ div [ class "flex-1 space-y-4 py-1 pl-4" ]
                        [ div [ class "h-4 bg-gray-400 rounded w-3/4" ]
                            []
                        , div [ class "space-y-4" ]
                            [ div [ class "h-4 bg-gray-400 rounded" ]
                                []
                            , div [ class "space-y-2 h-4 bg-gray-400 rounded w-5/6" ]
                                []
                            ]
                        ]
                    ]
                ]
    in
    div [ class "flex flex-col flex-grow space-y-8 py-8" ]
        [ loadingComponent
        , loadingComponent
        ]


deploymentsView : ModalState -> List Deployment -> String -> Html Msg
deploymentsView modalState deployments username =
    div [ class "px-0 md:px-4 py-5 sm:p-6 mb-4 justify-center flex flex-grow" ]
        [ case modalState of
            Closed ->
                ul [ class "flex flex-col mb-4 md:w-1/2 w-full" ]
                    (List.map deploymentCard deployments)

            Open deployment ->
                deleteModal deployment
        ]


deploymentCard : Deployment -> Html Msg
deploymentCard deployment =
    li [ class "h-40 flex mb-8 rounded-lg shadow w-full", style "background-color" Constants.deploymentCardBackgroundColor ]
        [ div [ class "w-full flex items-center justify-between" ]
            [ div [ class "flex flex-col px-2 md:px-8 py-4" ]
                [ div [ class "flex items-center space-x-3" ]
                    [ h3 [ class "text-blue-900 text-lg leading-5 font-medium truncate text-teal-800" ]
                        [ text deployment.subdomain ]
                    ]
                , p [ class "flex justify-start mt-1 text-gray-500 text-s  runcate" ]
                    [ text ("Deployment size: " ++ deployment.size) ]

                -- buttons below
                , div
                    [ class "flex flex-col px-0 pt-4 md:flex-row " ]
                    [ a
                        [ class "flex mx-2 md:w-1/2 w-1/2 h-8 bg-white shadow-md hover:bg-red-200 text-red-500 font-bold my-1 md:my-0 md:py-0 px-2 rounded-full"
                        , href "#"
                        , onClick (OpenDeleteModal deployment)
                        ]
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
                    , a
                        [ class "flex mx-2 w-3/4 md:w-full h-8 shadow-md bg-white text-indigo-400 hover:bg-indigo-200 font-bold my-1 md:my-0 md:py-0 px-2 rounded-full"
                        , href <| "https://drive.fission.codes/#/" ++ deployment.subdomain
                        , target "_blank"
                        ]
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

            -- End `visit` button
            , a
                [ class "hover:underline border-l border-gray-200 md:border-l md:border-0"
                , href "#"
                , style "color" Constants.visitButtonColor
                ]
                [ div [ class "px-8 py-8 flex " ]
                    [ span [ class "flex items-center " ]
                        [ h3 [ class "m-2 text-xl", style "color" Constants.visitButtonColor ]
                            [ text
                                "Visit"
                            ]
                        , svg [ SvgA.class "w-5 h-5 ", viewBox "0 0 24 24" ]
                            [ path [ d "M10 6H6C4.89543 6 4 6.89543 4 8V18C4 19.1046 4.89543 20 6 20H16C17.1046 20 18 19.1046 18 18V14M14 4H20M20 4V10M20 4L10 14", stroke Constants.visitButtonColor, strokeLinejoin "round", strokeWidth "2", fill "white" ]
                                []
                            ]
                        ]
                    ]
                ]
            ]
        ]


deleteModal : Deployment -> Html Msg
deleteModal deployment =
    div [ class "fixed bottom-0 inset-x-0 px-4 pb-4 sm:inset-0 sm:flex sm:items-center sm:justify-center" ]
        [ div [ class "fixed inset-0 transition-opacity" ]
            [ div [ class "absolute inset-0 bg-gray-500 opacity-75" ]
                []
            ]
        , div [ attribute "aria-labelledby" "modal-headline", attribute "aria-modal" "true", class "bg-white rounded-lg overflow-hidden shadow-xl transform transition-all sm:max-w-lg sm:w-full", attribute "role" "dialog" ]
            [ div [ class "bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4" ]
                [ div [ class "sm:flex sm:items-start" ]
                    [ div [ class "mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-red-100 sm:mx-0 sm:h-10 sm:w-10" ]
                        [ svg [ SvgA.class "h-8 w-8", viewBox "0 0 24 24" ]
                            [ path [ d "M12 9V11M12 15H12.01M5.07183 19H18.9282C20.4678 19 21.4301 17.3333 20.6603 16L13.7321 4C12.9623 2.66667 11.0378 2.66667 10.268 4L3.33978 16C2.56998 17.3333 3.53223 19 5.07183 19Z", strokeLinejoin "round", strokeWidth "2", fill "none", stroke "red" ]
                                []
                            ]
                        ]
                    , div [ class "mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left" ]
                        [ h3 [ class "text-lg leading-6 font-medium text-gray-900", id "modal-headline" ]
                            [ text "Delete Deployment" ]
                        , div [ class "mt-2" ]
                            [ p [ class "text-m leading-5 text-purple-900" ]
                                [ text (" -" ++ deployment.subdomain) ]
                            ]
                        , div [ class "mt-2" ]
                            [ p [ class "text-sm leading-5 text-gray-500" ]
                                [ text "Are you sure you want to delete your deployment? Your deployment and all of it's files will be removed. This action cannot be undone." ]
                            ]
                        ]
                    ]
                ]
            , div [ class "bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse" ]
                [ span [ class "flex w-full rounded-md shadow-sm sm:ml-3 sm:w-auto" ]
                    [ button [ class "inline-flex justify-center w-full rounded-md border border-transparent px-4 py-2 bg-red-600 text-base leading-6 font-medium text-white shadow-sm hover:bg-red-500 focus:outline-none focus:border-red-700 focus:shadow-outline-red transition ease-in-out duration-150 sm:text-sm sm:leading-5", type_ "button" ]
                        [ text "Delete" ]
                    ]
                , span [ class "mt-3 flex w-full rounded-md shadow-sm sm:mt-0 sm:w-auto" ]
                    [ button [ class "inline-flex justify-center w-full rounded-md border border-gray-300 px-4 py-2 bg-white text-base leading-6 font-medium text-gray-700 shadow-sm hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue transition ease-in-out duration-150 sm:text-sm sm:leading-5", type_ "button", onClick CloseDeleteModal ]
                        [ text "Cancel" ]
                    ]
                ]
            ]
        ]


errorView : String -> Html msg
errorView errorString =
    div [ class "flex flex-col flex-grow justify-start " ]
        [ h3 [ class "text-2xl my-12" ] [ text errorString ]
        , h3 [ class "text-xl" ] [ text "Please try again later" ]

        -- FIXME make these error messages nice
        , h3 [ class "text-xl py-2" ]
            [ text "& the meantime you can look at our "
            , a
                [ style "color" Constants.titleColor
                , class "underline"
                , href "https://guide.fission.codes/hosting/getting-started"
                ]
                [ text "getting started guide" ]
            , text " or even jump into our "
            , a
                [ style "color" Constants.titleColor
                , class "underline"
                , href "https://discord.gg/daDMAjE"
                ]
                [ text "discord" ]
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
