module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App as Html
import Json.Decode as Json exposing ((:=))
import Http
import Task
import Project exposing (..)
import Ports exposing (..)


type alias Model =
    { projects : List Project.Model
    }


init : ( Model, Cmd Msg )
init =
    ( Model [], getInitialProjects )



-- UPDATE


type Msg
    = NoOp
    | FetchFail Http.Error
    | FetchSucceed (List Project.Model)
    | NewProject Project.Model


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
    in
        div
            [ id "container"
            , class "wall"
            ]
            [ content
            , div [ class "events" ] []
            ]


viewProjects : Model -> Html Msg
viewProjects model =
    div [ class "projects-list" ]
        (List.map Project.view model.projects)


viewPlaceholder : Model -> Html Msg
viewPlaceholder model =
    div [ class "placeholder" ]
        [ text "There are no projects." ]



-- HTTP


getInitialProjects : Cmd Msg
getInitialProjects =
    Task.perform FetchFail FetchSucceed (Http.get decodeProjectsData "/api/projects")


decodeProjectsData : Json.Decoder (List Project.Model)
decodeProjectsData =
    Json.at [ "data" ] (Json.list Project.decoder)



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
