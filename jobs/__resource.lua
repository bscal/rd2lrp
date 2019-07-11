dependency "vrp"

server_script {
    "@vrp/lib/utils.lua",
    "server.lua"
}

client_script {
    "@vrp/lib/utils.lua",
    "init.lua"
}

files {
    "lib/Luaoop.lua",
    "lib/Tunnel.lua",
    "lib/Proxy.lua",
    "lib/IDManager.lua",
    "lib/ActionDelay.lua",
    "lib/Luang.lua",
    "configs/business.lua",
    "client.lua",
    "client-jobs.lua",
    "gang/c-gang.lua",
    "stores/c-stores.lua",
    "gang/s-gang.lua",
    "stores/s-stores.lua",
    "businesses/c-business.lua"
}
