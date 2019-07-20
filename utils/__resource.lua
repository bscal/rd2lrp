dependency "vrp"

server_script {
    "@vrp/lib/utils.lua",
    "server.lua",
    --"server-utils.lua"
}

client_script {
    "@vrp/lib/utils.lua",
    "init.lua",
    --"client.lua"
    -- "client-phone.lua"
}

-- ui_page("public/index.html")

files {
    -- "public/index.html",
    -- "public/main.js",
    -- "public/style.css",
    -- "public/icons/contacts.png",
    -- "public/icons/phone.png",
    -- "public/icons/text.png",
    -- "public/icons/twitter.png",
    -- "public/cursor.png",
    -- "public/background.png",
    -- "public/phone-frame.png",
    "lib/Luaoop.lua",
    "lib/Tunnel.lua",
    "lib/Proxy.lua",
    "lib/IDManager.lua",
    "lib/ActionDelay.lua",
    "lib/Luang.lua",
    "client.lua",
    "client-twitter.lua",
    "client-mechanic.lua",
    "client-weed.lua",
    "client-mask.lua"
    -- "client-phone.lua"
}
