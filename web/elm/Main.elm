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
    , projectForm : ProjectForm
    , username : String
    }


type alias Flags =
    { username : String }


init : Flags -> ( Model, Cmd Msg )
init { username } =
    let
        ( projectFormModel, projectFormEffects ) =
            ProjectForm.init

        effects =
            Cmd.batch
                [ Cmd.map ApiMsg Api.getAll
                , Cmd.map ProjectFormMsg projectFormEffects
                ]
    in
        ( Model ProjectList.initialModel projectFormModel username, effects )



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
                ( projectForm, projectFormEffects ) =
                    ProjectForm.update childMsg model.projectForm
            in
                ( { model | projectForm = projectForm }, Cmd.map ProjectFormMsg projectFormEffects )

        NewProjectForm ->
            let
                ( projectFormModel, projectFormEffects ) =
                    ProjectForm.update ProjectForm.Open model.projectForm

                effects =
                    Cmd.map ProjectFormMsg projectFormEffects
            in
                { model
                    | projectForm = projectFormModel
                }
                    ! [ effects ]

        ProjectMsg msg ->
            case msg of
                Project.DestroyProject project ->
                    model ! [ Cmd.map ApiMsg <| Api.destroy project ]

                Project.EditProjectForm project ->
                    let
                        ( projectForm, effects ) =
                            ProjectForm.update (ProjectForm.Edit project) model.projectForm
                    in
                        { model
                            | projectForm = projectForm
                        }
                            ! [ Cmd.map ProjectFormMsg effects ]

                _ ->
                    model ! []



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ id "container"
        , class "wall"
        ]
        [ viewNewProjectForm model
        , viewNav model.username
        , Html.App.map ProjectMsg <| ProjectList.view model.projects
        , div [ class "events" ] []
        ]


viewNav : String -> Html Msg
viewNav username =
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
                [ text username ]
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
    Html.App.map ProjectFormMsg (ProjectForm.view model.projectForm)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.newProjectNotifications (ProjectCreated << Project.parseRawProject)
        , Ports.updateProjectNotifications (ProjectUpdated << Project.parseRawProject)
        , Ports.deleteProjectNotifications (ProjectDestroyed << Project.parseRawProject)
        ]



-- WIRING


main : Program Flags
main =
    Html.App.programWithFlags
        { update = update
        , view = view
        , init = init
        , subscriptions = subscriptions
        }
