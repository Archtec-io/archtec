local http = assert(...)
local geoip = {}
archtec.geoip_enabled = true

if not minetest.get_player_ip then
	archtec.geoip_enabled = false
	minetest.log("error", "[geoip] minetest.get_player_ip not available!")
	return
end

-- TTL for cached results: 4 hours
local cache_ttl = 14400
local cache = {}

-- Execute cache cleanup every cache_ttl seconds
local function cache_cleanup()
	local expire = minetest.get_us_time() - (cache_ttl * 1000 * 1000)
	for ip, data in pairs(cache) do
		if expire > data.timestamp then
			cache[ip] = nil
		end
	end
	minetest.after(cache_ttl, cache_cleanup)
end
minetest.after(cache_ttl, cache_cleanup)

-- Main geoip lookup function, callback function gets result table as first argument
function geoip.lookup(ip, callback, playername)
	if cache[ip] then
		if playername and not cache[ip].players[playername] then
			cache[ip].players[playername] = minetest.get_us_time()
		end
		callback(cache[ip])
		return
	end
	http.fetch({
		url = "https://tools.keycdn.com/geo.json?host=" .. ip,
		extra_headers = {
			"User-Agent: keycdn-tools:https://archtec.niklp.net"
		},
		timeout = 1,
	}, function(res)
		if res.code == 200 and callback then
			local data = minetest.parse_json(res.data)
			if type(data) == "table" then
				local timestamp = minetest.get_us_time()
				local result = type(data.data) == "table" and type(data.data.geo) == "table" and data.data.geo or {}
				result.success = data.status == "success"
				result.status = data.status
				result.description = data.description
				result.timestamp = timestamp
				result.players = playername and {[playername]=timestamp} or {}
				cache[ip] = result
				callback(result)
				return
			end
		end
		minetest.log("warning", "[geoip] http request returned status: " .. res.code)
	end)
end

local function format_result(result)
	if result and result.success then
		local txt = ""
		if result.country_name then
			txt = txt .. " Country: " .. result.country_name
		end
		if result.city then
			txt = txt .. " City: " .. result.city
		end
		if result.timezone then
			txt = txt .. " Timezone: " .. result.timezone
		end
		if result.asn then
			txt = txt .. " ASN: " .. result.asn
		end
		if result.isp then
			txt = txt .. " ISP: " .. result.isp
		end
		if result.ip then
			txt = txt .. " IP: " .. result.ip
		end
		return txt
	else
		return false
	end
end

-- query ip on join, record in logs and execute callback
minetest.register_on_joinplayer(function(player)
	if not archtec.geoip_enabled then return end -- Kill switch

	local name = player:get_player_name()
	local ip = minetest.get_player_ip(name)
	if not ip then
		minetest.log("warning", "[geoip] get player IP address failed: " .. name)
		return
	end

	if ip == "127.0.0.1" then return end

	geoip.lookup(ip, function(data)
		local txt = format_result(data)
		if txt then
			notifyTeam("[geoip] Result for player '" .. name .. "': " .. txt)
		else
			notifyTeam("[geoip] Lookup failed for '" .. name .. "@" .. ip .. "' Reason: " .. tostring(data.description))
		end
	end, name)
end)

local function format_message(name, result)
	local txt = format_result(result)
	if not txt then
		return "Geoip error: " .. (result.description or "unknown error")
	end
	minetest.log("action", "[geoip] result for player " .. name .. ": " .. txt)
	return txt
end

local function format_matches_by_name(name)
	local formatted_results = {}
	local now = minetest.get_us_time()
	local count = 0
	for _, result in pairs(cache) do
		if result.players[name] then
			table.insert(formatted_results, {
				time = now - result.players[name],
				txt = format_message(name, result)
			})
			count = count + 1
		end
	end
	if count > 0 then
		table.sort(formatted_results, function(a,b)
			return a.time < b.time
		end)
		local msg = ""
		for i = 1, count do
			local s = math.floor(formatted_results[i].time / 1000000)
			local m = math.floor(s / 60) % 60
			local h = math.floor(s / 60 / 60)
			local time = ("%dh %dm %ds ago: "):format(h, m, s % 60)
			msg = msg .. time .. formatted_results[i].txt .. (i < count and "\n" or "")
		end
		return msg
	end
end

-- manual query
minetest.register_chatcommand("geoip", {
	params = "<name>",
	privs = {staff = true},
	description = "Does a geoip lookup on the given player",
	func = function(name, param)
		if not param then
			return true, "usage: /geoip <name>"
		end

		minetest.log("action", "[geoip] Player " .. name .. " queries the player: " .. param)

		local ip = minetest.get_player_ip(param)

		if ip then
			-- go through lookup if ip is available, this might still return cached result
			geoip.lookup(ip, function()
				local msg = format_matches_by_name(param) or "No matching geoip results found."
				minetest.chat_send_player(name, msg)
			end, param)
		else
			local msg = format_matches_by_name(param) or "No ip or cached result available."
			return true, msg
		end

	end
})
