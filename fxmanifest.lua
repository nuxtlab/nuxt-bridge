fx_version 'cerulean'
game 'gta5'

author 'cool0356'
description 'Intuitive bridge system by Nuxt Lab.'
repository 'https://github.com/nuxtlab/nuxt-bridge'
version '0.0.6'

files {
    'collection/*.json',
    'data/*.lua',
    '.output/*',
	'.output/**/*',
    'locale/*.lua',
    'module/**/*.lua'
}

ui_page '.output/index.html'

client_script 'client/*.lua'

server_script 'server/*.lua'

shared_script 'shared/*.lua'

use_experimental_fxv2_oal 'yes'
lua54 'yes'
