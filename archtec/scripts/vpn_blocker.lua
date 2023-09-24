local http = assert(...)
local iphub_key = minetest.settings:get("iphub_key")

archtec.vpn_enabled = true

if not iphub_key or iphub_key == "" then
	archtec.vpn_enabled = false
	minetest.log("warning", "[archtec] No IPHub key provided!")
	return
end

local cache = {}
local ttl = 14400 -- 4 h

local function cleanup()
	local expire = os.time() - ttl
	for ip, d in pairs(cache) do
		if d.expire < expire then
			cache[ip] = nil
		end
	end
	minetest.after(ttl, cleanup)
end
minetest.after(ttl, cleanup)

local function check_ip(name, ip)
	if not cache[ip] then return end
	if cache[ip].result == 0 then
		minetest.log("action", "[archtec_vpn_blocker] Passing good-ip-player " .. name .. " [" .. ip .. "]")
	else
		minetest.log("action", "[archtec_vpn_blocker] Kicking bad-ip-player " .. name .. " [" .. ip .. "]")
		notifyTeam("[archtec_vpn_blocker] Kicking bad-ip-player ".. name .."' (IP: " .. ip .. ")")
		minetest.after(0.01, function()
			if minetest.get_player_by_name(name) then
				minetest.log("action", "[archtec_vpn_blocker] kicked '" .. name .. "'")
				minetest.kick_player(name, "Please turn off your VPN.")
			end
		end)
	end
end

local function query_ip(name, ip)
	local request = {
		["url"] = "https://v2.api.iphub.info/ip/" .. ip,
		["extra_headers"] = {"X-Key: " .. iphub_key}
	}
	http.fetch(request, function(result)
		if result.code == 429 then
			return
		end
		local data = minetest.parse_json(result.data)
		if result.completed and result.succeeded and data and data.block then
			cache[ip] = {result = data.block, expire = os.time()}
			check_ip(name, ip)
		else
			return
		end
	end)
end

local function vpn_check(name, ip, query)
	if not archtec.vpn_enabled then return end -- Kill switch
	if not cache[ip] and query then
		query_ip(ip)
		return
	end
	check_ip()
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local ip = minetest.get_player_ip(name)
	if name and ip then
		vpn_check(name, ip, true)
	end
end)

--[[ Won't work yet
minetest.register_on_authplayer(function(name, ip, is_success)
	if is_success then
		if name and ip then
			vpn_check(name, ip, false) -- Don't query a http request but block if in cache
		end
	end
end)
]]---