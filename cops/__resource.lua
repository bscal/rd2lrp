resource_manifest_version '77731fab-63ca-442c-a67b-abc70f28dfa5'

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
    "client.lua",
    "c-cops-abilities.lua",
    "c-cops-dispatch.lua"
}
