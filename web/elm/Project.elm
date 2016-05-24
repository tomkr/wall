module Project exposing (..)

import Html exposing (..)
import Html.Attributes exposing (id, class)
import Json.Decode as Json exposing ((:=))


-- MODEL


type alias Model =
    { id : Int
    , name : String
    , masterBuildStatus : BuildStatus
    , latestBuildStatus : BuildStatus
    }


type BuildStatus
    = Success
    | Failed
    | Pending
    | Unknown



-- VIEW


view : Model -> Html x
view project =
    let
        domId =
            "project-" ++ (toString project.id)
    in
        div
            [ id domId
            , class "project"
            ]
            [ viewTitle project.name
            , viewBuildStatus project
            ]


viewTitle : String -> Html x
viewTitle name =
    div [ class "project__title" ]
        [ text name ]


viewBuildStatus : Model -> Html x
viewBuildStatus project =
    div [ class "project__build-status" ]
        [ viewBuildBadge "primitive-dot" project.masterBuildStatus
        , viewBuildBadge "git-branch" project.latestBuildStatus
        ]


viewBuildBadge : String -> BuildStatus -> Html x
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
        span [ class ("badge " ++ className) ]
            [ i [ class ("mega-octicon octicon-" ++ icon) ] []
            ]


decoder : Json.Decoder Model
decoder =
    Json.object4 Model
        ("id" := Json.int)
        ("name" := Json.string)
        ("masterBuildStatus" := buildStatusDecoder)
        ("latestBuildStatus" := buildStatusDecoder)


parseBuildStatus : Maybe String -> Result String BuildStatus
parseBuildStatus value =
    case value of
        Just "success" ->
            Result.Ok Success

        Just "failed" ->
            Result.Ok Failed

        Just "pending" ->
            Result.Ok Pending

        _ ->
            Result.Ok Unknown


buildStatusDecoder : Json.Decoder BuildStatus
buildStatusDecoder =
    Json.customDecoder (Json.maybe Json.string) parseBuildStatus
