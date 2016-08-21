// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
// import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import socket from "./socket";

window.init = function(options) {
  window.app = Elm.Main.fullscreen(options);
  const channel = socket.channel("notifications:lobby", {});
  channel.on("newProject", payload => {
    try {
      app.ports.newProjectNotifications.send(payload);
    } catch(e) {
      console.error(e);
    }
  });
  channel.on("updateProject", payload => {
    try {
      app.ports.updateProjectNotifications.send(payload);
    } catch(e) {
      console.error(e);
    }
  });
  channel.on("deleteProject", payload => {
    try {
      app.ports.deleteProjectNotifications.send(payload);
    } catch(e) {
      console.error(e);
    }
  });
};
