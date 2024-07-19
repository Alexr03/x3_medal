fx_version 'cerulean'
game 'gta5'

author 'Alexr03 <me@alexr03.dev>'
description 'Medal Integration. Code by: Alexr03'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
	'utilities/logger.lua',
    'config/config.lua',
    'config/*.lua',
	'utilities/util_*.lua',
}

client_scripts {
    'client/client.lua',
    'client/client_*.lua'
}

ui_page 'html/index.html'
files {
	'html/**/*',
}

escrow_ignore {
    'utilities/*',
    'config/*',
    'client/client_menu.lua'
}
