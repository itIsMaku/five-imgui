fx_version 'cerulean'
games { 'gta5' }
author 'maku#5434'
description 'first imgui implementation for lua using nui'

client_scripts {
    'client/cl_main.lua',
    'dependencies/screen2world.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/**/*.js',
    'html/**/*.css'
}
