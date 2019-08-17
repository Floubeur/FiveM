description 'ESX Blanchimment d\'argent'


client_scripts {
  '@es_extended/locale.lua',
  'locales/fr.lua',
  'config.lua',
  'client/main.lua',
  'client/Mission/gofast.lua',
  'client/Mission/killNPC.lua'

}

server_scripts {
  '@mysql-async/lib/MySQL.lua',
  '@es_extended/locale.lua',
  'locales/fr.lua',
  'config.lua',
  'server/main.lua'
}
