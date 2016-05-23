module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App as Html
import Json.Decode as Json exposing ((:=))
import Http
import Task exposing (andThen)


type alias Event =
    { id : Int
    , topic : String
    , status : String
    , date : String
    , subtopic : String
    , notes : String
    , projectId : Int
    }


type alias Project =
    { id : Int
    , name : String
    }


type alias Model =
    { events : List Event
    , projects : List Project
    }


init : ( Model, Cmd Msg )
init =
    ( Model [] [], getInitialProjects )



-- UPDATE


type Msg
    = NoOp
    | FetchFail Http.Error
    | FetchEvents (List Event)
    | FetchProjects (List Project)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        FetchEvents events ->
            ( { model | events = events }, Cmd.none )

        FetchProjects projects ->
            ( { model | projects = projects }, getInitialEvents )

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
        , if List.length model.events > 0 then
            div [ class "events" ]
                (List.map viewEvent model.events)
          else
            div [ class "placeholder" ]
                [ text "There are no events." ]
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


viewEvent : Event -> Html Msg
viewEvent event =
    let
        domId =
            "event-" ++ (toString event.id)
    in
        div
            [ id domId
            , class "event"
            ]
            [ text (toString event) ]



-- HTTP


getInitialProjects : Cmd Msg
getInitialProjects =
    Task.perform FetchFail FetchProjects (Http.get decodeProjectsData "/api/projects")


decodeProjectsData : Json.Decoder (List Project)
decodeProjectsData =
    Json.at [ "data" ] (Json.list projectDecoder)


projectDecoder : Json.Decoder Project
projectDecoder =
    Json.object2 Project
        ("id" := Json.int)
        ("name" := Json.string)


getInitialEvents : Cmd Msg
getInitialEvents =
    Task.perform FetchFail FetchEvents (Http.get decodeEventsData "/api/events")


decodeEventsData : Json.Decoder (List Event)
decodeEventsData =
    Json.at [ "data" ] (Json.list eventDecoder)


eventDecoder : Json.Decoder Event
eventDecoder =
    Json.object7 Event
        ("id" := Json.int)
        ("topic" := Json.string)
        ("status" := Json.string)
        ("date" := Json.string)
        ("subtopic" := Json.string)
        ("notes" := Json.string)
        ("projectId" := Json.int)



-- WIRING


main =
    Html.program
        { update = update
        , view = view
        , init = init
        , subscriptions = subscriptions
        }
