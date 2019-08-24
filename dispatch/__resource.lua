dependency 'vrp'

server_script {
    "@vrp/lib/utils.lua",
    "server.lua"
}

client_script {
    "@vrp/lib/utils.lua",
    "init.lua",
}

files {
    "client.lua",
    "client-cmds.lua"
}
