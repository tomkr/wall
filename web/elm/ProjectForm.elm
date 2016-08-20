module ProjectForm exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, type', id, for, value, disabled, href)
import Html.Events exposing (onInput, onSubmit, onClick)
import Json.Decode
import Json.Encode
import Api
import String
import Task
import Http
import Json.Decode
import Project exposing (Project)


-- MODEL


type alias Errors =
    List String


type alias ProjectForm =
    { name : ( Maybe String, Errors )
    , waiting : Bool
    , postError : Maybe String
    , isNew : Bool
    , id : Maybe Int
    }


initialProjectForm : ProjectForm
initialProjectForm =
    { name = ( Nothing, [] )
    , waiting = False
    , postError = Nothing
    , isNew = True
    , id = Nothing
    }


fromProject : Project -> ProjectForm
fromProject project =
    { initialProjectForm
        | name = ( Just project.name, [] )
        , isNew = False
        , id = Just project.id
    }


init : ( ProjectForm, Cmd Msg )
init =
    ( initialProjectForm, Cmd.none )


type Msg
    = SetName String
    | Submit
    | Cancel
    | ApiMsg Api.Msg



-- FUNCTIONS


isValid : ProjectForm -> Bool
isValid model =
    let
        hasErrors =
            model.name
                |> snd
                |> List.isEmpty

        isFilledOut =
            case fst model.name of
                Just str ->
                    True

                Nothing ->
                    False
    in
        hasErrors && isFilledOut


validatePresence : String -> Errors
validatePresence str =
    if String.isEmpty str then
        [ "is required" ]
    else
        []



-- UPDATE


update : Msg -> ProjectForm -> ( ProjectForm, Cmd Msg )
update msg model =
    case msg of
        SetName str ->
            { model | name = ( Just str, (validatePresence str) ) } ! []

        Submit ->
            let
                name =
                    model.name
                        |> fst
                        |> Maybe.withDefault ""
            in
                if isValid model then
                    { model | waiting = True } ! [ Cmd.map ApiMsg <| Api.create name ]
                else
                    model ! []

        Cancel ->
            init

        ApiMsg msg ->
            case msg of
                Api.CreateFailed error ->
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

                Api.UpdateFailed error ->
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

                _ ->
                    init



-- VIEW


view : ProjectForm -> Html Msg
view model =
    let
        modelName =
            Maybe.withDefault "" (fst model.name)

        errors =
            snd model.name

        hasErrors =
            List.isEmpty errors

        inputClassName =
            "input string"
                ++ if hasErrors then
                    ""
                   else
                    " with-errors"
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
                    [ class inputClassName
                    ]
                    [ label
                        [ for "project-form-name" ]
                        [ text "Name" ]
                    , input
                        [ id "project-form-name"
                        , type' "text"
                        , onInput SetName
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


viewControls : ProjectForm -> Html Msg
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

        label =
            if model.isNew then
                "Create Project"
            else
                "Update Project"
    in
        if model.waiting then
            div [] [ text "Please wait..." ]
        else
            div
                [ class "controls" ]
                [ input
                    [ type' "submit"
                    , value label
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
