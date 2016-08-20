module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.App as Html
import Json.Decode as Json exposing ((:=))
import Json.Encode
import Http
import Task
import Project exposing (..)
import Ports exposing (..)
import ProjectForm


type alias Model =
    { projects : List Project.Model
    , newProjectFormVisible : Bool
    , newProject : ProjectForm.Model
    }


init : ( Model, Cmd Msg )
init =
    let
        ( projectFormModel, projectFormEffects ) =
            ProjectForm.initialModel

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
    | FetchSucceed (List Project.Model)
    | NewProject Project.Model
    | ProjectFormMsg ProjectForm.Msg
    | ShowProjectForm
    | DestroyProject Project.Model
    | DestroyFail Http.Error
    | DestroySucceed Project.Model String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        FetchSucceed projects ->
            ( { model | projects = (List.sortBy .id projects) }, Cmd.none )

        FetchFail err ->
            ( model, Cmd.none )

        NewProject project ->
            let
                newProjects =
                    model.projects
                        |> List.filter (\p -> p.id /= project.id)
                        |> List.append [ project ]
                        |> List.sortBy .id
            in
                ( { model | projects = newProjects }, Cmd.none )

        ProjectFormMsg childMsg ->
            let
                ( newProject, projectFormEffects ) =
                    ProjectForm.update childMsg model.newProject

                newModel =
                    { model | newProject = newProject }

                effects =
                    Cmd.map ProjectFormMsg projectFormEffects
            in
                case childMsg of
                    ProjectForm.Cancel ->
                        ( { newModel | newProjectFormVisible = False }, effects )

                    ProjectForm.PostSucceed model ->
                        ( { newModel | newProjectFormVisible = False }, effects )

                    _ ->
                        ( newModel, effects )

        ShowProjectForm ->
            ( { model | newProjectFormVisible = True }, Cmd.none )

        DestroyProject project ->
            ( model, destroyProject project )

        DestroyFail error ->
            -- todo we could use some error alerting or flashing here
            ( model, Cmd.none )

        DestroySucceed project body ->
            let
                projects =
                    model.projects
                        |> List.filter (\p -> p.id /= project.id)
            in
                ( { model | projects = projects }, Cmd.none )



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

        newProjectForm =
            if model.newProjectFormVisible then
                viewNewProjectForm model
            else
                div [] []
    in
        div
            [ id "container"
            , class "wall"
            ]
            [ newProjectForm
            , a
                [ onClick ShowProjectForm ]
                [ text "Add Project" ]
            , content
            , div [ class "events" ] []
            ]


viewNewProjectForm : Model -> Html Msg
viewNewProjectForm model =
    div
        [ class "dialog" ]
        [ (Html.map
            ProjectFormMsg
            (ProjectForm.view model.newProject)
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


viewProject : Project.Model -> Html Msg
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


viewControls : Project.Model -> Html Msg
viewControls project =
    div [ class "project__controls" ]
        [ a
            [ class "minibutton"
            , onClick <| DestroyProject project
            ]
            [ text "×" ]
        ]


viewTitle : String -> Html Msg
viewTitle name =
    div [ class "project__title" ]
        [ text name ]


viewBuildStatus : Project.Model -> Html Msg
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


decodeProjectsData : Json.Decoder (List Project.Model)
decodeProjectsData =
    Json.at [ "data" ] (Json.list Project.decoder)


destroyProject : Project.Model -> Cmd Msg
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
    notifications (NewProject << Project.parseRawModel)



-- WIRING


main =
    Html.program
        { update = update
        , view = view
        , init = init
        , subscriptions = subscriptions
        }
