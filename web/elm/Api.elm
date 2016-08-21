module Api exposing (..)

import Http
import Task
import Json.Decode exposing ((:=))
import Project exposing (Project)
import ProjectList exposing (ProjectList)


-- MODEL


type Msg
    = FetchFailed Http.Error
    | FetchSucceeded ProjectList
    | DestroyFailed Http.Error
    | DestroySucceeded String
    | CreateFailed Http.Error
    | CreateSucceeded String
    | UpdateFailed Http.Error
    | UpdateSucceeded String
    | GetTokenFailed Http.Error
    | GetTokenSucceeded String



-- FUNCTIONS


getAll : String -> Cmd Msg
getAll token =
    let
        url =
            Http.url "/api/projects" [ ( "token", token ) ]
    in
        url
            |> Http.get decodeProjectsData
            |> Task.perform FetchFailed FetchSucceeded


create : String -> String -> Cmd Msg
create token name =
    let
        body =
            Http.multipart
                [ Http.stringData "project[name]" name
                , Http.stringData "token" token
                ]
    in
        body
            |> Http.post emptyStringDecoder "/api/projects"
            |> Task.perform CreateFailed CreateSucceeded


update : String -> Project -> Cmd Msg
update token project =
    let
        body =
            Http.multipart
                [ Http.stringData "project[name]" project.name
                , Http.stringData "_method" "patch"
                , Http.stringData "token" token
                ]
    in
        body
            |> Http.post emptyStringDecoder ("/api/projects/" ++ (toString project.id))
            |> Task.perform UpdateFailed UpdateSucceeded


destroy : String -> Project -> Cmd Msg
destroy token project =
    let
        url =
            "/api/projects/" ++ (toString project.id)

        body =
            Http.multipart
                [ Http.stringData "_method" "delete"
                , Http.stringData "token" token
                ]
    in
        Http.post emptyStringDecoder url body
            |> Task.perform DestroyFailed DestroySucceeded


eventToken : String -> Project -> Cmd Msg
eventToken token project =
    let
        url =
            Http.url ("/api/projects/" ++ (toString project.id) ++ "/token") [ ( "token", token ) ]
    in
        url
            |> Http.get decodeTokenData
            |> Task.perform GetTokenFailed GetTokenSucceeded



-- DECODERS


decodeTokenData : Json.Decode.Decoder String
decodeTokenData =
    Json.Decode.at [ "token" ] Json.Decode.string


decodeProjectsData : Json.Decode.Decoder ProjectList
decodeProjectsData =
    Json.Decode.at [ "data" ] (Json.Decode.list Project.decoder)


emptyStringDecoder : Json.Decode.Decoder String
emptyStringDecoder =
    Json.Decode.succeed ""
