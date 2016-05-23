module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App as Html
import Json.Decode as Json exposing ((:=))
import Http
import Task exposing (andThen)


type alias Project =
    { id : Int
    , name : String
    }


type alias Model =
    { projects : List Project
    }


init : ( Model, Cmd Msg )
init =
    ( Model [], getInitialProjects )



-- UPDATE


type Msg
    = NoOp
    | FetchFail Http.Error
    | FetchSucceed (List Project)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        FetchSucceed projects ->
            ( { model | projects = projects }, Cmd.none )

        FetchFail err ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ if List.length model.projects > 0 then
            div [ class "projects" ]
                (List.map viewProject model.projects)
          else
            div [ class "placeholder" ]
                [ text "There are no projects." ]
        ]


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
            [ text project.name ]



-- HTTP


getInitialProjects : Cmd Msg
getInitialProjects =
    Task.perform FetchFail FetchSucceed (Http.get decodeProjectsData "/api/projects")


decodeProjectsData : Json.Decoder (List Project)
decodeProjectsData =
    Json.at [ "data" ] (Json.list projectDecoder)


projectDecoder : Json.Decoder Project
projectDecoder =
    Json.object2 Project
        ("id" := Json.int)
        ("name" := Json.string)



-- WIRING


main =
    Html.program
        { update = update
        , view = view
        , init = init
        , subscriptions = subscriptions
        }
