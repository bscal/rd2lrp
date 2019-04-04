dependency 'vrp'
dependency 'cops'

server_script {
    "@vrp/lib/utils.lua",
    "server.lua"
}

client_script {
    "@vrp/lib/utils.lua",
    "init.lua",
}

files {
    "lib/Luaoop.lua",
    "lib/Tunnel.lua",
    "lib/Proxy.lua",
    "lib/IDManager.lua",
    "lib/ActionDelay.lua",
    "lib/Luang.lua",
    "client.lua",
    "client-cmds.lua"
}
