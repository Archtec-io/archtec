local MP = minetest.get_modpath("archtec_mapserver")
dofile(MP .. "/bridge/defaults.lua")
dofile(MP .. "/bridge/players.lua")

local http, url, key

local function send_stats()
	local t0 = minetest.get_us_time()

	-- data to send to mapserver
	local data = {}

	mapserver.bridge.add_players(data)
	mapserver.bridge.add_defaults(data)

	local json = minetest.write_json(data)

	local t1 = minetest.get_us_time()
	local process_time = t1 - t0
	if process_time > 50000 then
		minetest.log("warning", "[archtec_mapserver] processing took " .. process_time .. " us")
	end

	local size = string.len(json)
	if size > 256000 then
		minetest.log("warning", "[archtec_mapserver] json-size is " .. size .. " bytes")
	end

	http.fetch({
		url = url .. "/api/minetest",
		extra_headers = {"Content-Type: application/json", "Authorization: " .. key},
		timeout = 5,
		post_data = json
	}, function(res)
		local t2 = minetest.get_us_time()
		local post_time = t2 - t1
		if post_time > 1000000 then -- warn if over a second
			minetest.log("warning", "[archtec_mapserver] post took " .. post_time .. " us")
		end

		minetest.after(mapserver.send_interval, send_stats)
	end)

end

function mapserver.bridge_init(h, u, k)
	http = h
	url = u
	key = k

	minetest.after(mapserver.send_interval, send_stats)
end
