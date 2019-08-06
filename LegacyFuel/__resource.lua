resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

dependency "vrp"

server_scripts {
	"@vrp/lib/utils.lua",
	'source/server.lua',
	--'source/fuel_server.lua'
}

client_scripts {
	"@vrp/lib/utils.lua",
	--'config.lua',
	'source/client.lua',
	--'source/fuel_client.lua'
}

files {
	'config.lua',
	'source/fuel_client.lua'
}

exports {
	'GetFuel',
	'SetFuel'
}
