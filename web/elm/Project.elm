module Project exposing (..)

import Html exposing (..)
import Html.Attributes exposing (id, class)
import Json.Decode as Json exposing ((:=))


-- MODEL


type alias Model =
    { id : Int
    , name : String
    , masterBuildStatus : Maybe String
    , latestBuildStatus : Maybe String
    }



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
            [ viewTitle project.name ]


viewTitle : String -> Html x
viewTitle name =
    div [ class "project__title" ]
        [ text name ]


decoder : Json.Decoder Model
decoder =
    Json.object4 Model
        ("id" := Json.int)
        ("name" := Json.string)
        (Json.maybe ("masterBuildStatus" := Json.string))
        (Json.maybe ("latestBuildStatus" := Json.string))
