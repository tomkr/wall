module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.App
import Api
import Project exposing (Project)
import ProjectList exposing (ProjectList)
import Ports
import ProjectForm exposing (ProjectForm)


type alias Model =
    { projects : ProjectList
    , showProjectForm : Bool
    , editableProject : ProjectForm
    }


init : ( Model, Cmd Msg )
init =
    let
        ( projectFormModel, projectFormEffects ) =
            ProjectForm.init

        effects =
            Cmd.batch
                [ Cmd.map ApiMsg Api.getAll
                , Cmd.map ProjectFormMsg projectFormEffects
                ]
    in
        ( Model ProjectList.initialModel False projectFormModel, effects )



-- UPDATE


type Msg
    = NoOp
    | ApiMsg Api.Msg
    | ProjectCreated Project
    | ProjectUpdated Project
    | ProjectDestroyed Project
    | ProjectFormMsg ProjectForm.Msg
    | ProjectMsg Project.Msg
    | NewProjectForm


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        ApiMsg msg ->
            case msg of
                Api.FetchSucceeded projects ->
                    { model
                        | projects = ProjectList.sort projects
                    }
                        ! []

                _ ->
                    model ! []

        ProjectDestroyed project ->
            { model
                | projects = ProjectList.remove project model.projects
            }
                ! []

        ProjectCreated project ->
            { model
                | projects = ProjectList.append project model.projects
            }
                ! []

        ProjectUpdated project ->
            { model
                | projects = ProjectList.append project model.projects
            }
                ! []

        ProjectFormMsg childMsg ->
            let
                ( editableProject, projectFormEffects ) =
                    ProjectForm.update childMsg model.editableProject

                newModel =
                    { model | editableProject = editableProject }

                effects =
                    Cmd.map ProjectFormMsg projectFormEffects
            in
                case childMsg of
                    ProjectForm.Cancel ->
                        ( { newModel | showProjectForm = False }, effects )

                    ProjectForm.ApiMsg msg ->
                        case msg of
                            Api.CreateSucceeded _ ->
                                ( { newModel | showProjectForm = False }, effects )

                            Api.UpdateSucceeded _ ->
                                ( { newModel | showProjectForm = False }, effects )

                            _ ->
                                ( newModel, effects )

                    _ ->
                        ( newModel, effects )

        NewProjectForm ->
            { model
                | showProjectForm = True
                , editableProject = ProjectForm.initialProjectForm
            }
                ! []

        ProjectMsg msg ->
            case msg of
                Project.DestroyProject project ->
                    model ! [ Cmd.map ApiMsg <| Api.destroy project ]

                Project.EditProjectForm project ->
                    { model
                        | showProjectForm = True
                        , editableProject = ProjectForm.fromProject project
                    }
                        ! []

                _ ->
                    model ! []



-- VIEW


view : Model -> Html Msg
view model =
    let
        editableProjectForm =
            if model.showProjectForm then
                viewNewProjectForm model
            else
                div [] []
    in
        div
            [ id "container"
            , class "wall"
            ]
            [ editableProjectForm
            , viewNav
            , Html.App.map ProjectMsg <| ProjectList.view model.projects
            , div [ class "events" ] []
            ]


viewNav : Html Msg
viewNav =
    div
        [ class "nav" ]
        [ a
            [ onClick NewProjectForm
            , href "#"
            , title "Create a new project and add it to the wall"
            ]
            [ span
                [ class "octicon octicon-plus" ]
                []
            ]
        , span
            [ class "account" ]
            [ span
                [ class "octicon octicon-person" ]
                []
            , strong
                []
                [ text "avdgaag" ]
            ]
        , a
            [ class "octicon octicon-sign-out"
            , href "/logout"
            , title "Sign out"
            ]
            []
        ]


viewNewProjectForm : Model -> Html Msg
viewNewProjectForm model =
    div
        [ class "dialog" ]
        [ (Html.App.map
            ProjectFormMsg
            (ProjectForm.view model.editableProject)
          )
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.newProjectNotifications (ProjectCreated << Project.parseRawProject)
        , Ports.updateProjectNotifications (ProjectUpdated << Project.parseRawProject)
        , Ports.deleteProjectNotifications (ProjectDestroyed << Project.parseRawProject)
        ]



-- WIRING


main : Program Never
main =
    Html.App.program
        { update = update
        , view = view
        , init = init
        , subscriptions = subscriptions
        }
