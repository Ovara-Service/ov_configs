fx_version 'adamant'
game 'gta5'

version '1.0.0'
author 'Ovara.gg (Floex)'
description 'Configuration system'

shared_scripts {
    "config.lua",
    "shared/*.lua"
}

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "/server/*.lua"
}

client_scripts {
    "/client/*.lua"
}

ui_page 'client/html/index.html'

files {
    'client/html/index.html',
    'client/html/style.css',
    'client/html/scripts.js'
}