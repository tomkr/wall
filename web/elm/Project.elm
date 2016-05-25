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
            [ viewBuildStatus project
            , viewTitle project.name
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
