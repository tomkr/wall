port module Ports exposing (..)

import Project


port newProjectNotifications : (Project.RawModel -> msg) -> Sub msg


port updateProjectNotifications : (Project.RawModel -> msg) -> Sub msg


port deleteProjectNotifications : (Project.RawModel -> msg) -> Sub msg
