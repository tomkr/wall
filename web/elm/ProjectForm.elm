module ProjectForm exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, type', id, for, value, disabled, href, title)
import Html.Events exposing (onInput, onSubmit, onClick)
import Api
import String
import Http
import Project exposing (Project)
import Ports


-- MODEL


type alias Errors =
    List String


type alias Attribute =
    ( Maybe String, Errors )


type alias ProjectForm =
    { name : Attribute
    , waiting : Bool
    , postError : Maybe String
    , id : Maybe Int
    , isOpen : Bool
    , token : String
    , generatedToken : Maybe String
    }


initialProjectForm : String -> ProjectForm
initialProjectForm token =
    { name = ( Nothing, [] )
    , waiting = False
    , postError = Nothing
    , id = Nothing
    , isOpen = False
    , token = token
    , generatedToken = Nothing
    }


fromProject : Project -> ProjectForm -> ProjectForm
fromProject project projectForm =
    { projectForm
        | name = ( Just project.name, [] )
        , id = Just project.id
        , isOpen = True
    }


toProject : ProjectForm -> Result String Project
toProject projectForm =
    let
        name =
            attr .name projectForm
    in
        case projectForm.id of
            Just id ->
                Ok <| Project id name Project.Unknown Project.Unknown

            Nothing ->
                Err "could not create Project without an ID"


init : String -> ( ProjectForm, Cmd Msg )
init token =
    ( initialProjectForm token, Cmd.none )


type Msg
    = SetName String
    | Submit
    | Cancel
    | ApiMsg Api.Msg
    | Open
    | Edit Project
    | GenerateToken



-- FUNCTIONS


isNew : ProjectForm -> Bool
isNew model =
    case model.id of
        Just _ ->
            False

        Nothing ->
            True


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


attr : (ProjectForm -> Attribute) -> ProjectForm -> String
attr fun model =
    model
        |> fun
        |> fst
        |> Maybe.withDefault ""


addError : String -> ProjectForm -> ProjectForm
addError desc model =
    { model
        | waiting = False
        , postError = Just desc
    }


addHttpError : Http.Error -> ProjectForm -> ProjectForm
addHttpError error model =
    case error of
        Http.BadResponse code status ->
            addError "The endpoint was not found" model

        _ ->
            addError "An unknown error occured." model



-- UPDATE


update : Msg -> ProjectForm -> ( ProjectForm, Cmd Msg )
update msg model =
    case msg of
        Open ->
            { model | isOpen = True } ! [ Ports.focus "#project-form-name" ]

        Edit project ->
            fromProject project model ! [ Ports.focus "#project-form-name" ]

        SetName str ->
            { model | name = ( Just str, (validatePresence str) ) } ! []

        Submit ->
            let
                effects =
                    if isNew model then
                        model
                            |> attr .name
                            |> Api.create model.token
                            |> Cmd.map ApiMsg
                    else
                        case toProject model of
                            Ok project ->
                                project
                                    |> Api.update model.token
                                    |> Cmd.map ApiMsg

                            Err str ->
                                Cmd.none
            in
                if isValid model then
                    { model | waiting = True } ! [ effects ]
                else
                    model ! []

        Cancel ->
            init model.token

        GenerateToken ->
            let
                effects =
                    case toProject model of
                        Ok project ->
                            project
                                |> Api.eventToken model.token
                                |> Cmd.map ApiMsg

                        Err str ->
                            Cmd.none
            in
                model ! [ effects ]

        ApiMsg msg ->
            case msg of
                Api.CreateFailed error ->
                    addHttpError error model ! []

                Api.UpdateFailed error ->
                    addHttpError error model ! []

                Api.GetTokenFailed error ->
                    addHttpError error model ! []

                Api.GetTokenSucceeded token ->
                    { model | generatedToken = Just token } ! []

                _ ->
                    init model.token



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
        if model.isOpen then
            div
                [ class "dialog" ]
                [ div
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
                        , viewToken model
                        , viewControls model
                        ]
                    ]
                ]
        else
            div [] []


viewToken : ProjectForm -> Html Msg
viewToken model =
    let
        truncate =
            \n str -> (String.left n str) ++ "..." ++ (String.right n str)

        link =
            case model.generatedToken of
                Just token ->
                    span
                        []
                        [ a
                            [ href ("/api/events/" ++ token)
                            , title "Send events to this URL"
                            , class "token-generator__token"
                            ]
                            [ token |> truncate 10 |> text ]
                        , a
                            [ href "#"
                            , title "Generate a new secret URI to post events to"
                            , onClick GenerateToken
                            ]
                            [ span
                                [ class "octicon octicon-sync" ]
                                []
                            ]
                        ]

                Nothing ->
                    a
                        [ href "#"
                        , title "Generate a new secret URI to post events to"
                        , onClick GenerateToken
                        ]
                        [ text "Generate an API token"
                        ]
    in
        if isNew model then
            div [] []
        else
            div
                [ class "token-generator" ]
                [ span
                    [ class "octicon octicon-shield"
                    ]
                    []
                , link
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
            if isNew model then
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
