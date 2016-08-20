module Project exposing (..)

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



-- VIEW


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
