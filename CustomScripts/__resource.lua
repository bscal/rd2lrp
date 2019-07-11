-- server scripts
server_scripts {
  "@vrp/lib/utils.lua",
  "commands-server.lua",
  "deathmessages-server.lua",
  "weathersync-server.lua",
  "dispatch-server.lua"
}

-- client scripts
client_scripts {
  "cfg/config.lua",
  "pointfinger-client.lua",
  "handsup-client.lua",
  "stopwanted-client.lua",
  "deathmessages-client.lua",
  "missiontext-client.lua"
}

exports {
  "getSurrenderStatus"
}
