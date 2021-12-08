fx_version 'cerulean'
games      { 'gta5' }
lua54 'yes'

author 'KuzQuality | Kuzkay'
description 'Dragy made by KuzQuality'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/js/jquery.js',
    'html/js/chart.js',
    'html/fonts/FjallaOne.ttf',
    'html/index.html',
}


--
-- Client
--

client_scripts {
    'config.lua',
    'client/client.lua',
}

escrow_ignore {
    'config.lua',
    'client/client.lua',
}