port module Ports exposing (..)

import Project exposing (..)


port notifications : (Project.RawModel -> msg) -> Sub msg
