resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX door lock'

version '1.3.0'

server_scripts {
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'locales/pl.lua',
	'config.lua',
	'server/esx_doorlock_sv.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'locales/pl.lua',
	'config.lua',
	'client/esx_doorlock_cl.lua'
}

dependency 'es_extended'
