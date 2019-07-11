client_script {
    "@vrp/lib/utils.lua",
    "init.lua",
   -- "c-speed.lua"
    "c-cruise.lua",
    "c-fuel.lua",
    "c-belt.lua",
}

server_script {
    "@vrp/lib/utils.lua",
    "server.lua"
}

files {
    "lib/Luaoop.lua",
    "lib/Tunnel.lua",
    "c-cardoors.lua",
    "client.lua",
}