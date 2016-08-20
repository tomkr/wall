module ProjectForm exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, type', id, for, value, disabled, href)
import Html.Events exposing (onWithOptions, onSubmit, onClick, targetValue)
import Json.Decode
import Json.Encode
import Html.App
import String
import Task
import Http
import Json.Decode
import Project


-- MODEL


type alias Errors =
    List String


type alias Model =
    { name : ( Maybe String, Errors )
    , waiting : Bool
    , postError : Maybe String
    }


initialModel : ( Model, Cmd Msg )
initialModel =
    ( { name = ( Nothing, [] )
      , waiting = False
      , postError = Nothing
      }
    , Cmd.none
    )


type Msg
    = SetName String
    | Submit
    | Cancel
    | PostFail Http.Error
    | PostSucceed Project.Model



-- FUNCTIONS


validatePresence : String -> Errors
validatePresence str =
    if String.isEmpty str then
        [ "is required" ]
    else
        []



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetName str ->
            { model | name = ( Just str, (validatePresence str) ) } ! []

        Submit ->
            { model | waiting = True } ! [ postProject model ]

        Cancel ->
            initialModel

        PostFail error ->
            case error of
                Http.BadResponse code status ->
                    { model
                        | waiting = False
                        , postError = Just "The endpoint was not found."
                    }
                        ! []

                _ ->
                    { model
                        | waiting = False
                        , postError = Just "An unknown error occured."
                    }
                        ! []

        PostSucceed body ->
            initialModel



-- VIEW


view : Model -> Html Msg
view model =
    let
        modelName =
            Maybe.withDefault "" (fst model.name)

        errors =
            snd model.name
    in
        div
            [ class "project-form-wrapper" ]
            [ h2
                [ class "project-form-title" ]
                [ text "Create Project" ]
            , viewPostError model.postError
            , form
                [ class "project-form"
                , onSubmit Submit
                ]
                [ div
                    [ class
                        ("input string"
                            ++ if List.isEmpty errors then
                                ""
                               else
                                " with-errors"
                        )
                    ]
                    [ label
                        [ for "project-form-name" ]
                        [ text "Name" ]
                    , input
                        [ id "project-form-name"
                        , type' "text"
                        , onWithOptions "input" { stopPropagation = True, preventDefault = False } (Json.Decode.map SetName targetValue)
                        , value modelName
                        ]
                        []
                    , ul
                        [ class "errors" ]
                        (List.map
                            (\error -> li [ class "error" ] [ text error ])
                            errors
                        )
                    ]
                , viewControls model
                ]
            ]


viewPostError : Maybe String -> Html Msg
viewPostError msg =
    case msg of
        Just str ->
            ul
                [ class "errors" ]
                [ li
                    [ class "error" ]
                    [ text str ]
                ]

        Nothing ->
            div [] []


viewControls : Model -> Html Msg
viewControls model =
    let
        hasErrors =
            case fst model.name of
                Just str ->
                    model.name
                        |> snd
                        |> List.isEmpty
                        |> not

                Nothing ->
                    True
    in
        if model.waiting then
            div [] [ text "waiting" ]
        else
            div
                [ class "controls" ]
                [ input
                    [ type' "submit"
                    , value "Create Project"
                    , disabled hasErrors
                    ]
                    []
                , text " or "
                , a
                    [ class "cancel"
                    , href "#"
                    , onClick Cancel
                    ]
                    [ text "cancel" ]
                ]



-- TASKS


postProject : Model -> Cmd Msg
postProject model =
    let
        name =
            model.name
                |> fst
                |> Maybe.withDefault ""

        body =
            Http.multipart
                [ Http.stringData "project[name]" name ]
    in
        body
            |> Http.post decodePostData "/api/projects"
            |> Task.perform PostFail PostSucceed


decodePostData : Json.Decode.Decoder (Project.Model)
decodePostData =
    Json.Decode.at [ "data" ] Project.decoder



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- WIRING


main =
    Html.App.program
        { init = initialModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
