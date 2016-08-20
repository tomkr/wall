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



-- FUNCTIONS


getAll : Cmd Msg
getAll =
    "/api/projects"
        |> Http.get decodeProjectsData
        |> Task.perform FetchFailed FetchSucceeded


create : String -> Cmd Msg
create name =
    let
        body =
            Http.multipart
                [ Http.stringData "project[name]" name
                ]
    in
        body
            |> Http.post emptyStringDecoder "/api/projects"
            |> Task.perform CreateFailed CreateSucceeded


update : Project -> Cmd Msg
update project =
    let
        body =
            Http.multipart
                [ Http.stringData "project[name]" project.name
                , Http.stringData "_method" "patch"
                ]
    in
        body
            |> Http.post emptyStringDecoder ("/api/projects/" ++ (toString project.id))
            |> Task.perform UpdateFailed UpdateSucceeded


destroy : Project -> Cmd Msg
destroy project =
    let
        url =
            "/api/projects/" ++ (toString project.id)

        body =
            Http.multipart
                [ Http.stringData "_method" "delete" ]
    in
        Http.post emptyStringDecoder url body
            |> Task.perform DestroyFailed DestroySucceeded



-- DECODERS


decodeProjectsData : Json.Decode.Decoder ProjectList
decodeProjectsData =
    Json.Decode.at [ "data" ] (Json.Decode.list Project.decoder)


emptyStringDecoder : Json.Decode.Decoder String
emptyStringDecoder =
    Json.Decode.succeed ""
