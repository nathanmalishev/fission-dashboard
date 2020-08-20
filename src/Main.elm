module Main exposing (..)

import AssocList as Dict exposing (Dict)
import Browser
import Constants
import Deployment exposing (Deployment, Key)
import Dict as StandardDict
import Html exposing (Html, a, button, div, h1, h2, h3, img, li, p, span, text, ul)
import Html.Attributes exposing (alt, attribute, class, href, id, src, style, target, type_)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (field, map2, string)
import Ports
import RemoteData exposing (RemoteData)
import User exposing (User)



-- MODEL ----


type alias Model =
    { deployments : RemoteData Http.Error (Dict Key Deployment)
    , user : User
    , deleteModal : ModalState
    , create : CreateState
    }


type CreateState
    = NotAsked
    | Loading
    | Error String


type ModalState
    = Open ( Key, Deployment )
    | Closed


type alias Flags =
    { user : Maybe String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( user, fetch, deployments ) =
            case flags.user of
                Just username ->
                    ( User.User username, Ports.fetchDeployments (), RemoteData.Loading )

                Nothing ->
                    ( User.Guest, Cmd.none, RemoteData.Loading )
    in
    ( { deployments = deployments
      , user = user
      , deleteModal = Closed
      , create = NotAsked
      }
    , fetch
    )



---- UPDATE ----


type Msg
    = -- UI
      OpenDeleteModal ( Key, Deployment )
    | CloseDeleteModal
      -- Trigger API calls
    | DeleteDeployment ( Key, Deployment )
    | CreateDeployment
      -- Recieve data
    | OnFetchedDeployments Decode.Value
    | OnDeletedDeployment (Result Ports.Error String)
    | OnCreatedDeployment (Result Ports.Error String)
      -- Others
    | Login
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CreateDeployment ->
            ( { model | create = Loading }, Ports.create () )

        Login ->
            ( model, Ports.login () )

        OpenDeleteModal ( key, deployment ) ->
            ( { model | deleteModal = Open ( key, deployment ) }, Cmd.none )

        CloseDeleteModal ->
            ( { model | deleteModal = Closed }, Cmd.none )

        OnCreatedDeployment result ->
            case model.deployments of
                RemoteData.Success deployments ->
                    case result of
                        Result.Ok subdomain ->
                            let
                                tempKey =
                                    "key" ++ subdomain

                                nDeployments =
                                    RemoteData.Success <|
                                        Dict.insert (Deployment.stringToKey tempKey) (Deployment.new subdomain) deployments
                            in
                            -- add subdomain to deployments
                            ( { model | deployments = nDeployments, create = NotAsked }, Cmd.none )

                        Result.Err _ ->
                            -- let user know
                            ( { model | create = Error "Something went wrong creating your new deployment" }
                            , Cmd.none
                            )

                _ ->
                    ( model, Cmd.none )

        OnDeletedDeployment result ->
            case model.deployments of
                RemoteData.Success deployments ->
                    case result of
                        Result.Ok stringKey ->
                            let
                                nDeployments =
                                    RemoteData.Success <|
                                        deleteDeployment (Deployment.stringToKey stringKey) deployments
                            in
                            ( { model | deployments = nDeployments }, Cmd.none )

                        Result.Err error ->
                            case error of
                                Ports.Network { key, err } ->
                                    let
                                        nDeployments =
                                            RemoteData.Success <|
                                                Dict.update (Deployment.stringToKey key) (Maybe.map (\v -> { v | delete = Deployment.Error err })) deployments
                                    in
                                    ( { model | deployments = nDeployments }, Cmd.none )

                                Ports.Unkown _ ->
                                    ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        DeleteDeployment ( key, deployment ) ->
            -- Call API to delete deployment, change deployment to loading state
            case model.deployments of
                RemoteData.Success deploymentValues ->
                    ( { model
                        | deleteModal = Closed
                        , deployments = RemoteData.Success (Dict.insert key { deployment | delete = Deployment.Deleting } deploymentValues)
                      }
                    , Ports.delete { key = Deployment.keyToString key, subdomain = deployment.subdomain }
                    )

                _ ->
                    ( model, Cmd.none )

        OnFetchedDeployments rawValues ->
            let
                deployments =
                    case Decode.decodeValue Ports.decoderDeployments2 rawValues of
                        Ok values ->
                            RemoteData.Success values

                        Err err ->
                            RemoteData.Failure (Http.BadBody (Decode.errorToString err))
            in
            ( { model | deployments = deployments }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



---- HELPERS -----


deleteDeployment : Key -> Dict Key Deployment -> Dict Key Deployment
deleteDeployment givenKey deployments =
    Dict.update givenKey (\_ -> Nothing) deployments


httpErrorToString : Http.Error -> String
httpErrorToString error =
    -- In the future we may want to provide a specific error
    "Sorry we couldn't seem to fetch your deployments right now."



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        isCreatingDeployment =
            case model.create of
                Loading ->
                    True

                _ ->
                    False

        content =
            -- auth check
            case model.user of
                User.User username ->
                    case model.deployments of
                        -- data state check
                        RemoteData.Success deployments ->
                            deploymentsView model.deleteModal deployments username isCreatingDeployment

                        RemoteData.Loading ->
                            -- FIXME may experience some flasing without a delay to loading
                            -- or a forced look at this loading for at least a second
                            loading

                        RemoteData.Failure e ->
                            httpErrorToString e
                                |> errorView

                User.Guest ->
                    User.guestView Login
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
                [ class "shadow rounded-md p-4 md:w-1/2 w-full mx-auto py-5 mb-4 h-40"
                , style "background-color" Constants.deploymentCardBackgroundColor
                ]
                [ div [ class "animate-pulse flex space-x-4" ]
                    [ div [ class "flex-1 space-y-4 py-3 pl-4" ]
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


deploymentsView : ModalState -> Dict Key Deployment -> String -> Bool -> Html Msg
deploymentsView modalState deployments username creatingNewDeployment =
    let
        deploymentCount =
            deployments
                |> Dict.toList
                |> List.length
    in
    -- we may want to add the user name in -- perhaps a search bar
    div [ class "px-0 md:px-4 py-5 sm:p-6 mb-4 justify-center flex flex-grow flex-col w-full content-center" ]
        [ User.welcomeTab username deploymentCount CreateDeployment creatingNewDeployment
        , ul [ class "self-center flex flex-col mb-4 md:w-3/4 xl:w-1/2 w-full sm:w-full" ]
            (List.map (Deployment.card OpenDeleteModal) (Dict.toList deployments))
        , case modalState of
            Closed ->
                div [] []

            Open ( key, deployment ) ->
                deleteModal ( key, deployment )
        ]


deleteModal : ( Key, Deployment ) -> Html Msg
deleteModal ( key, deployment ) =
    div [ class "fixed bottom-0 inset-x-0 px-4 pb-4 sm:inset-0 sm:flex sm:items-center sm:justify-center" ]
        [ div [ class "fixed inset-0 transition-opacity" ]
            [ div [ class "absolute inset-0 bg-gray-500 opacity-75" ]
                []
            ]
        , div [ attribute "aria-labelledby" "modal-headline", attribute "aria-modal" "true", class "bg-white rounded-lg overflow-hidden shadow-xl transform transition-all sm:max-w-lg sm:w-full", attribute "role" "dialog" ]
            [ div [ class "bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4" ]
                [ div [ class "sm:flex sm:items-start" ]
                    [ div [ class "mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-red-100 sm:mx-0 sm:h-10 sm:w-10" ]
                        [ div [ class "h-8 w-8" ] [ Constants.exclamation "red" ]
                        ]
                    , div [ class "mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left" ]
                        [ h3 [ class "text-lg leading-6 font-medium text-gray-900", id "modal-headline" ]
                            [ text "Delete Deployment" ]
                        , div [ class "mt-2" ]
                            [ ul [ class "text-m leading-5 text-purple-900" ]
                                [ li [] [ text deployment.subdomain ] ]
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
                    [ button
                        [ class "inline-flex justify-center w-full rounded-md border border-transparent px-4 py-2 bg-red-600 text-base leading-6 font-medium text-white shadow-sm hover:bg-red-500 focus:outline-none focus:border-red-700 focus:shadow-outline-red transition ease-in-out duration-150 sm:text-sm sm:leading-5"
                        , type_ "button"
                        , onClick (DeleteDeployment ( key, deployment ))
                        ]
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


main : Program Flags Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Ports.recieveDeployments OnFetchedDeployments
        , Ports.deleteDeployment (Ports.deleteDecoder >> OnDeletedDeployment)
        , Ports.createDeployment (Ports.createDecoder >> OnCreatedDeployment)
        ]
