--[[
	Config (minetest.conf)
	mapserver.url = http://127.0.0.1:7575
	mapserver.key = myserverkey
]]--

mapserver = {
	send_interval = tonumber(minetest.settings:get("mapserver.send_interval")) or 12.3,
	bridge = {}
}

local MP = minetest.get_modpath("archtec_mapserver")
dofile(MP.."/common.lua")
dofile(MP.."/poi.lua")

local http = minetest.request_http_api()

if http then
	-- check if the mapserver.json is in the world-folder
	local path = minetest.get_worldpath().."/mapserver.json";
	local mapserver_cfg

	local file = io.open(path, "r" );
	if file then
		local json = file:read("*all");
		mapserver_cfg = minetest.parse_json(json);
		file:close();
		print("[Mapserver] read settings from 'mapserver.json'")
	end

	local mapserver_url = minetest.settings:get("mapserver.url")
	local mapserver_key = minetest.settings:get("mapserver.key")

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

	print("[Mapserver] starting mapserver-bridge with endpoint: " .. mapserver_url)
	dofile(MP .. "/bridge/init.lua")

	-- initialize bridge
	mapserver.bridge_init(http, mapserver_url, mapserver_key)

else
	print("[Mapserver] bridge not active, additional infos will not be visible on the map")
end

print("[Mapserver] OK")
