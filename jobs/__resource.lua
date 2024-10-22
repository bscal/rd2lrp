dependency "vrp"
dependency "cops"

server_script {
    "@vrp/lib/utils.lua",
    "server.lua"
}

client_script {
    "@vrp/lib/utils.lua",
    "init.lua",
    --"gui/gui.lua"
}

--ui_page("public/index.html")

files {
    -- "public/index.html",
    -- "public/main.js",
    -- "public/style.css",
    -- "public/monitor.png",
    -- "public/logo.png",
    -- "public/cursor.png",
    "configs/business.lua",
    "client.lua",
    "client-jobs.lua",
    "gang/c-gang.lua",
    "stores/c-stores.lua",
    "gang/s-gang.lua",
    "stores/s-stores.lua",
    "businesses/c-business.lua"
}
