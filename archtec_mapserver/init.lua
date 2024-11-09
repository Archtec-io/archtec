mapserver = {
	send_interval = tonumber(core.settings:get("mapserver.send_interval")) or 7.1,
	bridge = {}
}

local MP = core.get_modpath("archtec_mapserver")
dofile(MP.."/common.lua")
dofile(MP.."/poi.lua")
dofile(MP.."/train.lua")

local http = core.request_http_api()

if http then
	-- check if the mapserver.json is in the world-folder
	local path = core.get_worldpath().."/mapserver.json";
	local mapserver_cfg

	local file = io.open(path, "r" );
	if file then
		local json = file:read("*all")
		mapserver_cfg = core.parse_json(json)
		file:close()
		core.log("action", "[archtec_mapserver] read settings from 'mapserver.json'")
	end

	local mapserver_url = core.settings:get("mapserver.url")
	local mapserver_key = core.settings:get("mapserver.key")

	if mapserver_cfg and mapserver_cfg.webapi then
		if not mapserver_key then
			-- apply key from json
			mapserver_key = mapserver_cfg.webapi.secretkey
		end
		if not mapserver_url then
			-- assemble url from json
			mapserver_url = "http://127.0.0.1:" .. mapserver_cfg.port
		end
	end

	if not mapserver_url then error("mapserver.url is not defined") end
	if not mapserver_key then error("mapserver.key is not defined") end

	core.log("action", "[archtec_mapserver] starting archtec_mapserver with endpoint: " .. mapserver_url)
	dofile(MP .. "/bridge/init.lua")

	-- initialize bridge
	mapserver.bridge_init(http, mapserver_url, mapserver_key)

else
	core.log("warning", "[archtec_mapserver] bridge not active, additional infos will not be visible on the map")
end

core.log("action", "[archtec_mapserver] loaded")
