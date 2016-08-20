module Project exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, title, id)
import Html.Events exposing (onClick)
import Json.Decode as Json exposing ((:=))


-- MODEL


type alias Project =
    { id : Int
    , name : String
    , masterBuildStatus : BuildStatus
    , latestBuildStatus : BuildStatus
    }


type alias RawProject =
    { id : Int
    , name : String
    , masterBuildStatus : Maybe String
    , latestBuildStatus : Maybe String
    }


type BuildStatus
    = Success
    | Failed
    | Pending
    | Unknown


type Msg
    = NoOp
    | EditProjectForm Project
    | DestroyProject Project



-- UPDATE


update : Msg -> Project -> Project
update msg model =
    case msg of
        NoOp ->
            model

        EditProjectForm project ->
            model

        DestroyProject project ->
            model



-- VIEW


view : Project -> Html Msg
view project =
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


viewBuildBadge : String -> BuildStatus -> Html Msg
viewBuildBadge icon buildStatus =
    let
        className =
            case buildStatus of
                Success ->
                    "badge--green"

                Failed ->
                    "badge--red"

                Pending ->
                    "badge--yellow"

                Unknown ->
                    "badge--gray"
    in
        span
            [ class ("badge " ++ className)
            ]
            [ i
                [ class ("mega-octicon octicon-" ++ icon) ]
                []
            ]



-- DECODING


decoder : Json.Decoder Project
decoder =
    Json.object4 Project
        ("id" := Json.int)
        ("name" := Json.string)
        ("masterBuildStatus" := buildStatusDecoder)
        ("latestBuildStatus" := buildStatusDecoder)


parseBuildStatus : String -> Result String BuildStatus
parseBuildStatus value =
    case value of
        "success" ->
            Ok Success

        "failed" ->
            Ok Failed

        "pending" ->
            Ok Pending

        "" ->
            Ok Unknown

        _ ->
            Err "Unexpected build status encountered"


buildStatusDecoder : Json.Decoder BuildStatus
buildStatusDecoder =
    let
        nullOrStringDecoder =
            Json.oneOf [ (Json.null ""), Json.string ]
    in
        Json.customDecoder nullOrStringDecoder parseBuildStatus


parseRawProject : RawProject -> Project
parseRawProject inputProject =
    let
        masterBuildStatus =
            inputProject.masterBuildStatus
                |> Maybe.withDefault ""
                |> parseBuildStatus
                |> Result.withDefault Unknown

        latestBuildStatus =
            inputProject.latestBuildStatus
                |> Maybe.withDefault ""
                |> parseBuildStatus
                |> Result.withDefault Unknown
    in
        Project inputProject.id inputProject.name masterBuildStatus latestBuildStatus
