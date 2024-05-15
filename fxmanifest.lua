fx_version 'cerulean'
game 'gta5'

author 'cool0356'
description 'Intuitive bridge system by Nuxt Lab.'
version '0.0.5'

files {
    'collection/*.json',
    'data/*.lua',
    'dist/*',
	'dist/**/*',
    'locale/*.lua',
    'module/**/*.lua'
}

ui_page 'dist/index.html'

shared_script 'shared/*.lua'

use_experimental_fxv2_oal 'yes'
lua54 'yes'
