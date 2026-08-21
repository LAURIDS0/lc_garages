fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'LC Development'
description 'Public, job-restricted and personal vehicle garages for Qbox'
version '1.1.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config/config.lua',
    'config/garages.lua'
}

client_scripts {
    'client/garages.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/garages.lua'
}

dependencies {
    'ox_lib',
    'oxmysql',
    'qbx_core',
    'qbx_vehiclekeys'
}
