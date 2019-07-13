dependency "vrp"
dependency "utils"

server_script {
    "@vrp/lib/utils.lua",
    "server.lua"
}

client_script {
    "@vrp/lib/utils.lua",
    "init.lua",
    "c-cops-abilities.lua"
}

export "isEmergencyJob"
export "isAdmin"
export "getPermLevel"
export "isHandcuffed"

files {
    "lib/Luaoop.lua",
    "lib/Tunnel.lua",
    "lib/Proxy.lua",
    "lib/IDManager.lua",
    "lib/ActionDelay.lua",
    "lib/Luang.lua",
    "init.lua",
    "client.lua",
    "c-cops-abilities.lua",
    "c-cops-dispatch.lua",
    "c-cops-ems.lua"
}
