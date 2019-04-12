
description "vRP lscustoms"
--ui_page "ui/index.html"

dependency "vrp"
dependency 'GHMattiMySQL'

client_scripts{ 
  "@vrp/lib/utils.lua",
  "init.lua",
  "client.lua"
}

server_scripts{ 
  "@vrp/lib/utils.lua",
  "init-server.lua"
}

files {
  "lib/Tunnel.lua",
  "lib/Proxy.lua",
  "init.lua"
}