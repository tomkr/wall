port module Ports exposing (..)

import Project exposing (RawProject)


port newProjectNotifications : (RawProject -> msg) -> Sub msg


port updateProjectNotifications : (RawProject -> msg) -> Sub msg


port deleteProjectNotifications : (RawProject -> msg) -> Sub msg
