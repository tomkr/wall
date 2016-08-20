module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.App as Html
import Json.Decode as Json exposing ((:=))
import Http
import Task
import Project exposing (Project)
import Ports
import ProjectForm exposing (ProjectForm)


type alias Model =
    { projects : List Project
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
                [ getInitialProjects
                , Cmd.map ProjectFormMsg projectFormEffects
                ]
    in
        ( Model [] False projectFormModel, getInitialProjects )



-- UPDATE


type Msg
    = NoOp
    | FetchFail Http.Error
    | FetchSucceed (List Project)
    | NewProject Project
    | UpdateProject Project
    | ProjectFormMsg ProjectForm.Msg
    | NewProjectForm
    | EditProjectForm Project
    | DestroyProject Project
    | DestroyFail Http.Error
    | DestroySucceed Project String
    | ProjectDestroyed Project


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        FetchSucceed projects ->
            ( { model | projects = (List.sortBy .id projects) }, Cmd.none )

        FetchFail err ->
            ( model, Cmd.none )

        ProjectDestroyed project ->
            let
                projects =
                    model.projects
                        |> List.filter (\p -> p.id /= project.id)
                        |> List.sortBy .id
            in
                ( { model | projects = projects }, Cmd.none )

        NewProject project ->
            let
                editableProjects =
                    model.projects
                        |> List.filter (\p -> p.id /= project.id)
                        |> List.append [ project ]
                        |> List.sortBy .id
            in
                ( { model | projects = editableProjects }, Cmd.none )

        UpdateProject project ->
            let
                projects =
                    model.projects
                        |> List.map
                            (\p ->
                                if p.id == project.id then
                                    project
                                else
                                    p
                            )
            in
                ( { model | projects = projects }, Cmd.none )

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

                    ProjectForm.PostSucceed str ->
                        ( { newModel | showProjectForm = False }, effects )

                    _ ->
                        ( newModel, effects )

        NewProjectForm ->
            ( { model
                | showProjectForm = True
                , editableProject = ProjectForm.initialProjectForm
              }
            , Cmd.none
            )

        EditProjectForm project ->
            ( { model
                | showProjectForm = True
                , editableProject = ProjectForm.fromProject project
              }
            , Cmd.none
            )

        DestroyProject project ->
            ( model, destroyProject project )

        DestroyFail error ->
            -- todo we could use some error alerting or flashing here
            ( model, Cmd.none )

        DestroySucceed project body ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    let
        anyProjects =
            List.length model.projects > 0

        content =
            if anyProjects then
                viewProjects model
            else
                viewPlaceholder model

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
            , content
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
        [ (Html.map
            ProjectFormMsg
            (ProjectForm.view model.editableProject)
          )
        ]


viewProjects : Model -> Html Msg
viewProjects model =
    div [ class "projects-list" ]
        (List.map viewProject model.projects)


viewPlaceholder : Model -> Html Msg
viewPlaceholder model =
    div [ class "placeholder" ]
        [ text "There are no projects!" ]


viewProject : Project -> Html Msg
viewProject project =
    let
        domId =
            "project-" ++ (toString project.id)
    in
        div
            [ id domId
            , class "project"
            ]
            [ viewBuildStatus project
            , viewTitle project.name
            , viewControls project
            ]


minibutton : String -> String -> msg -> Html msg
minibutton icon description msg =
    a
        [ class "minibutton"
        , title description
        , onClick msg
        ]
        [ span
            [ class ("octicon octicon-" ++ icon) ]
            []
        ]


viewControls : Project -> Html Msg
viewControls project =
    div [ class "project__controls" ]
        [ minibutton "gear" "Remove this project" (EditProjectForm project)
        , minibutton "trashcan" "Remove this project" (DestroyProject project)
        ]


viewTitle : String -> Html Msg
viewTitle name =
    div [ class "project__title" ]
        [ text name ]


viewBuildStatus : Project -> Html Msg
viewBuildStatus project =
    div [ class "project__build-status" ]
        [ viewBuildBadge "primitive-dot" project.masterBuildStatus
        , viewBuildBadge "git-branch" project.latestBuildStatus
        ]


viewBuildBadge : String -> Project.BuildStatus -> Html Msg
viewBuildBadge icon buildStatus =
    let
        className =
            case buildStatus of
                Project.Success ->
                    "badge--green"

                Project.Failed ->
                    "badge--red"

                Project.Pending ->
                    "badge--yellow"

                Project.Unknown ->
                    "badge--gray"
    in
        span [ class ("badge " ++ className) ]
            [ i [ class ("mega-octicon octicon-" ++ icon) ] []
            ]



-- HTTP


getInitialProjects : Cmd Msg
getInitialProjects =
    Task.perform FetchFail FetchSucceed (Http.get decodeProjectsData "/api/projects")


decodeProjectsData : Json.Decoder (List Project)
decodeProjectsData =
    Json.at [ "data" ] (Json.list Project.decoder)


destroyProject : Project -> Cmd Msg
destroyProject project =
    let
        url =
            "/api/projects/" ++ (toString project.id)

        decoder =
            Json.succeed ""

        body =
            Http.multipart
                [ Http.stringData "_method" "delete" ]
    in
        Http.post decoder url body
            |> Task.perform DestroyFail (DestroySucceed project)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.newProjectNotifications (NewProject << Project.parseRawProject)
        , Ports.updateProjectNotifications (UpdateProject << Project.parseRawProject)
        , Ports.deleteProjectNotifications (ProjectDestroyed << Project.parseRawProject)
        ]



-- WIRING


main : Program Never
main =
    Html.program
        { update = update
        , view = view
        , init = init
        , subscriptions = subscriptions
        }
