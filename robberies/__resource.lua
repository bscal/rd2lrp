resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

server_script {
    "@vrp/lib/utils.lua",
    "server.lua"
}

client_script {
    "@vrp/lib/utils.lua",
    "init.lua",
    "client.lua"
}

ui_page('public/index.html')

files {
    'public/index.html',
    'public/main.js',
    'public/style.css',
    "public/cursor.png",
    "client.lua",
    "client-stores.lua",
    "client-banks.lua"
}
