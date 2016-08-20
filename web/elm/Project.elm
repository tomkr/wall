module Project exposing (..)

import Json.Decode as Json exposing ((:=))


-- MODEL


type alias Model =
    { id : Int
    , name : String
    , masterBuildStatus : BuildStatus
    , latestBuildStatus : BuildStatus
    }


type alias RawModel =
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


parseRawModel : RawModel -> Model
parseRawModel inputModel =
    let
        masterBuildStatus =
            inputModel.masterBuildStatus
                |> Maybe.withDefault ""
                |> parseBuildStatus
                |> Result.withDefault Unknown

        latestBuildStatus =
            inputModel.latestBuildStatus
                |> Maybe.withDefault ""
                |> parseBuildStatus
                |> Result.withDefault Unknown
    in
        Model inputModel.id inputModel.name masterBuildStatus latestBuildStatus
